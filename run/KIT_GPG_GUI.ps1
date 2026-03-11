# =============================================================================
#  KIT_GPG_GUI.ps1  —  Interfaccia grafica WPF per KIT GPG v2.1
#  Avviare tramite avvia_GUI.cmd oppure:
#  powershell -ExecutionPolicy Bypass -File KIT_GPG_GUI.ps1
# =============================================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# -- Percorsi ----------------------------------------------------------------
$RUNDIR  = $PSScriptRoot
$BASEDIR = Split-Path $RUNDIR -Parent
$REPORTS = Join-Path $BASEDIR "reports"
$OUT_DIR = Join-Path $BASEDIR "out"

# -- Helper: avvia uno script CMD --------------------------------------------
#    -AutoRefresh: aggiorna il log dopo 5 secondi (per script che generano report)
function Invoke-KitScript {
    param(
        [string]$ScriptName,
        [string]$FileArg = "",
        [switch]$AutoRefresh
    )
    $scriptPath = Join-Path $RUNDIR $ScriptName
    if (-not (Test-Path $scriptPath)) {
        [System.Windows.MessageBox]::Show("Script non trovato:`n$scriptPath", "Errore", "OK", "Error") | Out-Null
        return
    }
    if ($FileArg) {
        $cmdArgs = "/c `"`"$scriptPath`" `"$FileArg`"`" & pause"
    } else {
        $cmdArgs = "/c `"`"$scriptPath`"`" & pause"
    }
    Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -WorkingDirectory $BASEDIR

    if ($AutoRefresh) {
        $script:refreshTimer = [System.Windows.Threading.DispatcherTimer]::new()
        $script:refreshTimer.Interval = [TimeSpan]::FromSeconds(5)
        $script:refreshTimer.Add_Tick({
            $script:refreshTimer.Stop()
            $script:refreshTimer = $null
            $txtLog.Text = Get-LatestReport
            Set-Status "Report aggiornato." "#3FB950"
        })
        $script:refreshTimer.Start()
    }
}

# -- Helper: ultimo report ---------------------------------------------------
function Get-LatestReport {
    if (Test-Path $REPORTS) {
        $latest = Get-ChildItem -Path $REPORTS -Filter "*.txt" -ErrorAction SilentlyContinue |
                  Sort-Object LastWriteTime -Descending |
                  Select-Object -First 1
        if ($latest) {
            $content = Get-Content $latest.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
            return "[ $($latest.Name) ]`r`n`r`n$content"
        }
    }
    return "Nessun report disponibile.`r`nEsegui un'operazione per generare il primo report."
}

# -- Helper: apri file dialog ------------------------------------------------
function Open-FileDialog {
    param([string]$Title, [string]$Filter)
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = $Title
    $dlg.Filter = $Filter
    $dlg.InitialDirectory = $BASEDIR
    if ($dlg.ShowDialog() -eq "OK") { return $dlg.FileName }
    return $null
}

# -- XAML --------------------------------------------------------------------
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="KIT GPG v2.1"
    Width="720" Height="660"
    MinWidth="620" MinHeight="560"
    Background="#0D1117"
    FontFamily="Segoe UI"
    WindowStartupLocation="CenterScreen"
    AllowDrop="True">

    <Window.Resources>
        <Style x:Key="OpButton" TargetType="Button">
            <Setter Property="Background"      Value="#161B22"/>
            <Setter Property="Foreground"      Value="#C9D1D9"/>
            <Setter Property="BorderBrush"     Value="#30363D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontFamily"      Value="Consolas"/>
            <Setter Property="FontSize"        Value="13"/>
            <Setter Property="Height"          Value="72"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background"  Value="#1C2B3A"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00B4D8"/>
                                <Setter Property="Foreground" Value="#00D4FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0A3A4A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecButton" TargetType="Button" BasedOn="{StaticResource OpButton}">
            <Setter Property="Height"   Value="32"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Padding"  Value="12,0"/>
        </Style>

        <Style x:Key="DarkTab" TargetType="TabItem">
            <Setter Property="Background"  Value="Transparent"/>
            <Setter Property="Foreground"  Value="#484F58"/>
            <Setter Property="BorderBrush" Value="#30363D"/>
            <Setter Property="FontFamily"  Value="Consolas"/>
            <Setter Property="FontSize"    Value="10"/>
            <Setter Property="FontWeight"  Value="Bold"/>
            <Setter Property="Padding"     Value="12,5"/>
            <Setter Property="Cursor"      Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="tabBorder"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="1,1,1,0"
                                Margin="0,0,3,0"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter ContentSource="Header"
                                              HorizontalAlignment="Center"
                                              VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="tabBorder" Property="Background"  Value="#161B22"/>
                                <Setter TargetName="tabBorder" Property="BorderBrush" Value="#30363D"/>
                                <Setter Property="Foreground" Value="#00D4FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="tabBorder" Property="Background" Value="#161B22"/>
                                <Setter Property="Foreground" Value="#8B949E"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="64"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="28"/>
        </Grid.RowDefinitions>

        <!-- HEADER -->
        <Border Grid.Row="0" Background="#161B22" BorderBrush="#21262D" BorderThickness="0,0,0,1">
            <Grid Margin="20,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="&#x1F512;" FontSize="22" VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <StackPanel VerticalAlignment="Center">
                        <TextBlock Text="KIT GPG PORTABILE" FontFamily="Consolas" FontSize="15"
                                   FontWeight="Bold" Foreground="#00D4FF"/>
                        <TextBlock Text="Sistema sicuro per la cifratura di file"
                                   FontSize="11" Foreground="#8B949E"/>
                    </StackPanel>
                </StackPanel>
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock x:Name="txtVersion" Text="v2.1" FontFamily="Consolas" FontSize="11"
                               Foreground="#484F58" VerticalAlignment="Center"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- GRIGLIA OPERAZIONI -->
        <Border Grid.Row="1" Margin="16,14,16,0">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition/>
                    <RowDefinition Height="8"/>
                    <RowDefinition/>
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition/>
                    <ColumnDefinition Width="8"/>
                    <ColumnDefinition/>
                    <ColumnDefinition Width="8"/>
                    <ColumnDefinition/>
                </Grid.ColumnDefinitions>

                <Button x:Name="btnSetupKeys" Grid.Row="0" Grid.Column="0" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x1F511;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Genera Chiavi" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="Setup_keys" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>

                <Button x:Name="btnSetupTrust" Grid.Row="0" Grid.Column="2" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x1F6E1;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Setup Trust" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="Setup_Trust" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>

                <Button x:Name="btnCifra" Grid.Row="0" Grid.Column="4" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x1F510;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Cifra e Firma" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="cifra" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>

                <Button x:Name="btnDecifra" Grid.Row="2" Grid.Column="0" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x1F513;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Decifra" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="decifra" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>

                <Button x:Name="btnVerifica" Grid.Row="2" Grid.Column="2" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x2705;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Verifica Firma" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="verifica" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>

                <Button x:Name="btnDiagnostica" Grid.Row="2" Grid.Column="4" Style="{StaticResource OpButton}">
                    <StackPanel HorizontalAlignment="Center">
                        <TextBlock Text="&#x1F50D;" FontSize="22" HorizontalAlignment="Center"/>
                        <TextBlock Text="Diagnostica" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock Text="diagnostica" FontSize="10" Foreground="#484F58" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Button>
            </Grid>
        </Border>

        <!-- DROP ZONE -->
        <Border x:Name="dropZone" Grid.Row="2" Margin="16,10,16,0"
                Background="#0D1117" BorderBrush="#30363D" BorderThickness="1"
                CornerRadius="6" Height="56" AllowDrop="True">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                <TextBlock Text="&#x1F4C2;" FontSize="18" VerticalAlignment="Center" Margin="0,0,8,0"/>
                <StackPanel VerticalAlignment="Center">
                    <TextBlock x:Name="txtDropHint"
                               Text="Trascina qui un file per Cifrare, Decifrare o Verificare"
                               FontFamily="Consolas" FontSize="11" Foreground="#8B949E"/>
                    <TextBlock x:Name="txtDropFile" Text=""
                               FontFamily="Consolas" FontSize="11" Foreground="#00D4FF"
                               Visibility="Collapsed"/>
                </StackPanel>
            </StackPanel>
        </Border>

        <!-- TAB: REPORT + GUIDA RAPIDA -->
        <TabControl Grid.Row="3" Margin="16,10,16,8">
            <TabControl.Template>
                <ControlTemplate TargetType="TabControl">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <TabPanel Grid.Row="0" IsItemsHost="True"
                                  Background="Transparent" Margin="0,0,0,-1" Panel.ZIndex="1"/>
                        <Border Grid.Row="1" Background="#0D1117"
                                BorderBrush="#30363D" BorderThickness="1" Padding="0">
                            <ContentPresenter ContentSource="SelectedContent"/>
                        </Border>
                    </Grid>
                </ControlTemplate>
            </TabControl.Template>
            <TabControl.Resources>
                <Style TargetType="TabItem" BasedOn="{StaticResource DarkTab}"/>
            </TabControl.Resources>

            <!-- Tab 1: Ultimo Report -->
            <TabItem Header="&#x1F4CB;  ULTIMO REPORT">
                <Grid Margin="0,8,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0" Margin="8,0,8,6">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="6"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Button x:Name="btnRefresh" Grid.Column="1"
                                Style="{StaticResource SecButton}" Content="&#x21BB; Aggiorna"/>
                        <Button x:Name="btnOpenReports" Grid.Column="3"
                                Style="{StaticResource SecButton}" Content="&#x1F4C1; Apri cartella"/>
                    </Grid>
                    <Border Grid.Row="1" Margin="8,0,8,8" BorderBrush="#21262D" BorderThickness="1" CornerRadius="4">
                        <TextBox x:Name="txtLog"
                                 Background="#010409" Foreground="#8B949E"
                                 FontFamily="Consolas" FontSize="11"
                                 IsReadOnly="True" TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"
                                 HorizontalScrollBarVisibility="Auto"
                                 BorderThickness="0" Padding="10"/>
                    </Border>
                </Grid>
            </TabItem>

            <!-- Tab 2: Guida Rapida -->
            <TabItem Header="&#x1F4D6;  GUIDA RAPIDA">
                <ScrollViewer VerticalScrollBarVisibility="Auto"
                              HorizontalScrollBarVisibility="Disabled"
                              Background="#010409">
                    <StackPanel Margin="14,10,14,14" Background="#010409">

                        <TextBlock Text="SETUP INIZIALE  (una tantum)"
                                   FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                                   Foreground="#00D4FF" Margin="0,4,0,8"/>

                        <StackPanel Margin="0,0,0,6">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#3FB950"
                                       Text="  1  Genera Chiavi"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="     Pulsante [Genera Chiavi] &#x2192; inserisci Nome, Email, Passphrase"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#484F58" Margin="0,1,0,0"
                                       Text="     Output: public_key_&lt;Nome&gt;.asc nella root del kit"/>
                        </StackPanel>

                        <StackPanel Margin="0,0,0,6">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#3FB950"
                                       Text="  2  Setup Trust    &#x26A0; OBBLIGATORIO prima del primo uso"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="     Copia publickey.asc + fingerprint.txt in trust\"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,1,0,0"
                                       Text="     Pulsante [Setup Trust] &#x2192; segui le istruzioni a video"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#484F58" Margin="0,1,0,0"
                                       Text="     Trust FULL(4) con verifica singola  |  ULTIMATE(5) con doppia verifica"/>
                        </StackPanel>

                        <StackPanel Margin="0,0,0,4">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#3FB950"
                                       Text="  3  Invia la tua chiave pubblica alla controparte"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="     Consegna public_key_&lt;Nome&gt;.asc via email / PEC / portale"/>
                        </StackPanel>

                        <Border Height="1" Background="#21262D" Margin="0,8,0,8"/>

                        <TextBlock Text="USO QUOTIDIANO"
                                   FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                                   Foreground="#00D4FF" Margin="0,0,0,8"/>

                        <StackPanel Margin="0,0,0,6">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#F0A500"
                                       Text="  CIFRA      [Cifra e Firma]  oppure  trascina qualsiasi file qui"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="             Scegli destinatari &#x2192; conferma &#x2192; Passphrase in Pinentry"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#484F58" Margin="0,1,0,0"
                                       Text="             Output: out\&lt;nomefile&gt;.gpg"/>
                        </StackPanel>

                        <StackPanel Margin="0,0,0,6">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#F0A500"
                                       Text="  DECIFRA    [Decifra]  oppure  trascina .gpg &#x2192; scegli [S&#xEC;]"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="             Output nella stessa cartella del .gpg, senza estensione"/>
                        </StackPanel>

                        <StackPanel Margin="0,0,0,4">
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#F0A500"
                                       Text="  VERIFICA   [Verifica Firma]  oppure  trascina .gpg &#x2192; scegli [No]"/>
                            <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,2,0,0"
                                       Text="             Il report appare automaticamente nel tab Ultimo Report"/>
                        </StackPanel>

                        <Border Height="1" Background="#21262D" Margin="0,8,0,8"/>

                        <TextBlock Text="ESITI VERIFICA FIRMA"
                                   FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                                   Foreground="#00D4FF" Margin="0,0,0,8"/>

                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#3FB950" Margin="0,0,0,3"
                                   Text="  GOOD SIGNATURE (TRUST OK)        firma valida &#x2714;"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#D29922" Margin="0,0,0,3"
                                   Text="  SIGNATURE OK / TRUST non verif.  esegui Setup Trust"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#F85149" Margin="0,0,0,3"
                                   Text="  BAD SIGNATURE                    file compromesso &#x2718;"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#D29922" Margin="0,0,0,4"
                                   Text="  Chiave pubblica assente           esegui Setup Trust"/>

                        <Border Height="1" Background="#21262D" Margin="0,6,0,8"/>

                        <TextBlock Text="TROUBLESHOOTING RAPIDO"
                                   FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                                   Foreground="#00D4FF" Margin="0,0,0,8"/>

                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,3"
                                   Text="  Nessuna chiave privata      &#x2192;  esegui Genera Chiavi"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,3"
                                   Text="  Bad passphrase              &#x2192;  riprova, controlla CAPS LOCK e layout"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,3"
                                   Text="  TRUST not confirmed          &#x2192;  esegui Setup Trust"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,3"
                                   Text="  Fingerprint non corrisponde  &#x2192;  contatta mittente fuori banda"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,3"
                                   Text="  Percorso con &amp; o accenti    &#x2192;  sposta kit in E:\KIT_GPG"/>
                        <TextBlock FontFamily="Consolas" FontSize="10" Foreground="#8B949E" Margin="0,0,0,8"
                                   Text="  Diagnostica completa         &#x2192;  pulsante [Diagnostica]"/>

                    </StackPanel>
                </ScrollViewer>
            </TabItem>

        </TabControl>

        <!-- STATUS BAR -->
        <Border Grid.Row="4" Background="#161B22" BorderBrush="#21262D" BorderThickness="0,1,0,0">
            <Grid Margin="16,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock x:Name="txtStatus"
                           Text="Pronto - seleziona un'operazione o trascina un file"
                           FontFamily="Consolas" FontSize="10"
                           Foreground="#484F58" VerticalAlignment="Center"/>
                <TextBlock x:Name="txtBasedir" Grid.Column="1"
                           FontFamily="Consolas" FontSize="10"
                           Foreground="#30363D" VerticalAlignment="Center"/>
            </Grid>
        </Border>

    </Grid>
</Window>
'@


# -- Carica la finestra ------------------------------------------------------
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Riferimenti ai controlli
$btnSetupKeys   = $window.FindName("btnSetupKeys")
$btnSetupTrust  = $window.FindName("btnSetupTrust")
$btnCifra       = $window.FindName("btnCifra")
$btnDecifra     = $window.FindName("btnDecifra")
$btnVerifica    = $window.FindName("btnVerifica")
$btnDiagnostica = $window.FindName("btnDiagnostica")
$btnRefresh     = $window.FindName("btnRefresh")
$btnOpenReports = $window.FindName("btnOpenReports")
$txtLog         = $window.FindName("txtLog")
$txtStatus      = $window.FindName("txtStatus")
$txtBasedir     = $window.FindName("txtBasedir")
$txtDropHint    = $window.FindName("txtDropHint")
$txtDropFile    = $window.FindName("txtDropFile")
$dropZone       = $window.FindName("dropZone")

# -- Init --------------------------------------------------------------------
$txtBasedir.Text = $BASEDIR
$txtLog.Text     = Get-LatestReport

function Set-Status {
    param([string]$msg, [string]$color = "#484F58")
    $txtStatus.Text       = $msg
    $txtStatus.Foreground = $color
}

# -- Handler pulsanti --------------------------------------------------------
$btnSetupKeys.Add_Click({
    Set-Status "Avvio Setup_keys.cmd..." "#00D4FF"
    Invoke-KitScript "Setup_keys.cmd"
    Set-Status "Setup_keys avviato in finestra separata." "#00D4FF"
})

$btnSetupTrust.Add_Click({
    Set-Status "Avvio Setup_Trust.cmd..." "#00D4FF"
    Invoke-KitScript "Setup_Trust.cmd" -AutoRefresh
    Set-Status "Setup_Trust avviato in finestra separata." "#00D4FF"
})

$btnCifra.Add_Click({
    $file = Open-FileDialog -Title "Seleziona il file da cifrare" `
                            -Filter "Tutti i file (*.*)|*.*"
    if ($file) {
        Set-Status "Avvio cifratura: $(Split-Path $file -Leaf)" "#00D4FF"
        Invoke-KitScript "cifra.cmd" $file -AutoRefresh
        Set-Status "cifra.cmd avviato in finestra separata." "#00D4FF"
    }
})

$btnDecifra.Add_Click({
    $file = Open-FileDialog -Title "Seleziona il file .gpg da decifrare" `
                            -Filter "File GPG (*.gpg)|*.gpg|Tutti i file (*.*)|*.*"
    if ($file) {
        Set-Status "Avvio decifratura: $(Split-Path $file -Leaf)" "#00D4FF"
        Invoke-KitScript "decifra.cmd" $file -AutoRefresh
        Set-Status "decifra.cmd avviato in finestra separata." "#00D4FF"
    }
})

$btnVerifica.Add_Click({
    $file = Open-FileDialog -Title "Seleziona il file .gpg da verificare" `
                            -Filter "File GPG (*.gpg)|*.gpg|Tutti i file (*.*)|*.*"
    if ($file) {
        Set-Status "Avvio verifica firma: $(Split-Path $file -Leaf)" "#00D4FF"
        Invoke-KitScript "verifica.cmd" $file -AutoRefresh
        Set-Status "verifica.cmd avviato in finestra separata." "#00D4FF"
    }
})

$btnDiagnostica.Add_Click({
    Set-Status "Avvio diagnostica..." "#F0A500"
    Invoke-KitScript "diagnostica.cmd" -AutoRefresh
    Set-Status "diagnostica.cmd avviato in finestra separata." "#00D4FF"
})

$btnRefresh.Add_Click({
    $txtLog.Text = Get-LatestReport
    Set-Status "Report aggiornato." "#3FB950"
})

$btnOpenReports.Add_Click({
    if (Test-Path $REPORTS) {
        Start-Process "explorer.exe" $REPORTS
    } else {
        Set-Status "Cartella reports non trovata." "#F85149"
    }
})

# -- Drag & Drop -------------------------------------------------------------
$window.Add_DragOver({
    param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)) {
        $e.Effects = [System.Windows.DragDropEffects]::Copy
    } else {
        $e.Effects = [System.Windows.DragDropEffects]::None
    }
    $e.Handled = $true
})

$window.Add_Drop({
    param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)) {
        $files = $e.Data.GetData([System.Windows.DataFormats]::FileDrop)
        $file  = $files[0]
        $name  = Split-Path $file -Leaf

        $txtDropFile.Text       = $name
        $txtDropFile.Visibility = "Visible"
        $txtDropHint.Visibility = "Collapsed"

        if ($file -match '\.gpg$') {
            $result = [System.Windows.MessageBox]::Show(
                "File: $name`n`nCosa vuoi fare?`n`n[Si] Decifra`n[No] Verifica Firma",
                "File GPG rilevato",
                [System.Windows.MessageBoxButton]::YesNoCancel,
                [System.Windows.MessageBoxImage]::Question
            )
            if ($result -eq "Yes") {
                Set-Status "Avvio decifratura: $name" "#00D4FF"
                Invoke-KitScript "decifra.cmd" $file -AutoRefresh
            } elseif ($result -eq "No") {
                Set-Status "Avvio verifica firma: $name" "#00D4FF"
                Invoke-KitScript "verifica.cmd" $file -AutoRefresh
            }
        } else {
            $result = [System.Windows.MessageBox]::Show(
                "File: $name`n`nCifrare e firmare questo file?",
                "Cifratura",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Question
            )
            if ($result -eq "Yes") {
                Set-Status "Avvio cifratura: $name" "#00D4FF"
                Invoke-KitScript "cifra.cmd" $file -AutoRefresh
            }
        }

        # Ripristina hint dopo 4 secondi
        $script:dropResetTimer = [System.Windows.Threading.DispatcherTimer]::new()
        $script:dropResetTimer.Interval = [TimeSpan]::FromSeconds(4)
        $script:dropResetTimer.Add_Tick({
            $script:dropResetTimer.Stop()
            $script:dropResetTimer = $null
            $txtDropFile.Visibility = "Collapsed"
            $txtDropHint.Visibility = "Visible"
        })
        $script:dropResetTimer.Start()
    }
    $e.Handled = $true
})

# -- Avvia -------------------------------------------------------------------
$window.ShowDialog() | Out-Null
