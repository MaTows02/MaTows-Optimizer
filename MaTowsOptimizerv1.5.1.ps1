<#
    ===========================================================================
    MATOWS OPTIMIZER - V1.5.1 (FIX ICONES)
    ===========================================================================
#>

# 0. GESTION ERREURS
Trap {
    Write-Host "`n[ERREUR]" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Appuyez sur ENTREE..."
    Exit
}

# 1. ADMIN CHECK
if ($host.Runspace.ApartmentState -ne 'STA') {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -PassThru
    Exit
}

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. INTERFACE GRAPHIQUE
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MaTows Optimizer - V1.5.1" Height="950" Width="1350" 
        WindowStartupLocation="CenterScreen" Background="#121212" Foreground="White">

    <Window.Resources>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#E0E0E0"/> <Setter Property="FontSize" Value="14"/> <Setter Property="Cursor" Value="Hand"/> <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#252526"/> <Setter Property="Foreground" Value="White"/> <Setter Property="BorderBrush" Value="#00BFFF"/> <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style x:Key="HelpIcon" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#00BFFF"/> <Setter Property="FontWeight" Value="Bold"/> <Setter Property="FontSize" Value="14"/> <Setter Property="Margin" Value="0,0,10,0"/> <Setter Property="Cursor" Value="Help"/> <Setter Property="Text" Value="(?)"/> <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style x:Key="TitleText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#00BFFF"/> <Setter Property="FontWeight" Value="Bold"/> <Setter Property="FontSize" Value="16"/> <Setter Property="Margin" Value="0,15,0,10"/>
        </Style>
        <Style x:Key="SubTitle" TargetType="TextBlock">
            <Setter Property="Foreground" Value="Gray"/> <Setter Property="FontSize" Value="11"/> <Setter Property="Margin" Value="0,10,0,2"/>
        </Style>
        <Style x:Key="InfoText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="White"/> <Setter Property="FontSize" Value="13"/> <Setter Property="FontWeight" Value="Bold"/> <Setter Property="TextWrapping" Value="Wrap"/> <Setter Property="Margin" Value="0,0,0,5"/>
        </Style>
        <Style x:Key="BtnAction" TargetType="Button">
            <Setter Property="Background" Value="#333"/> <Setter Property="Foreground" Value="#00BFFF"/> <Setter Property="FontSize" Value="11"/> <Setter Property="Padding" Value="10,5"/> <Setter Property="Margin" Value="0,5,0,10"/> <Setter Property="BorderThickness" Value="0"/> <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" BorderThickness="1,1,1,0" BorderBrush="#333" Margin="2,0" CornerRadius="5,5,0,0">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="20,10"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#00BFFF"/> <Setter Property="Foreground" Value="Black"/> <Setter Property="FontWeight" Value="Bold"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#1E1E1E"/> <Setter Property="Foreground" Value="Gray"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions> <ColumnDefinition Width="420"/> <ColumnDefinition Width="*"/> </Grid.ColumnDefinitions>

        <Border Grid.Column="0" Background="#1E1E1E" BorderBrush="#333" BorderThickness="0,0,1,0">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <StackPanel Margin="20">
                    <TextBlock Text="MON PC" FontSize="24" FontWeight="Bold" Foreground="White" Margin="0,0,0,20"/>

                    <Border Background="#252525" CornerRadius="8" Padding="15" Margin="0,0,0,20">
                        <StackPanel>
                            <TextBlock Text="SYSTEME" Foreground="Gray" FontSize="11"/>
                            <TextBlock Name="lblPcType" Text="..." FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,5"/>
                            <TextBlock Name="lblOS" Text="Windows..." FontSize="12" Foreground="Silver"/>
                        </StackPanel>
                    </Border>

                    <TextBlock Text="STOCKAGE" Style="{StaticResource SubTitle}"/>
                    <TextBlock Name="lblStorage" Text="Analyse..." Style="{StaticResource InfoText}"/>

                    <TextBlock Text="PROCESSEUR" Style="{StaticResource SubTitle}"/>
                    <TextBlock Name="lblCPU" Text="..." Style="{StaticResource InfoText}"/>
                    <TextBlock Name="lblCpuDate" Text="..." FontSize="11" Foreground="#888" Margin="0,0,0,5"/>
                    <Button Name="btnUpdCPU" Content="[MAJ PILOTES CPU]" Style="{StaticResource BtnAction}"/>

                    <TextBlock Text="CARTE GRAPHIQUE" Style="{StaticResource SubTitle}"/>
                    <TextBlock Name="lblGPU" Text="..." Style="{StaticResource InfoText}"/>
                    <TextBlock Name="lblGpuDate" Text="..." FontSize="11" Foreground="#888" Margin="0,0,0,5"/>
                    <Button Name="btnUpdGPU" Content="[TELECHARGER PILOTES]" Style="{StaticResource BtnAction}"/>
                    
                    <TextBlock Text="RAM" Style="{StaticResource SubTitle}"/>
                    <TextBlock Name="lblRAM" Text="..." FontSize="14" FontWeight="Bold" Foreground="White"/>
                    <TextBlock Name="lblXMP" Text="..." FontSize="13" FontWeight="Bold" Foreground="Gray" Margin="0,2,0,5"/>
                    <Button Name="btnTutoRAM" Content="[ACTIVER XMP/EXPO]" Style="{StaticResource BtnAction}" Visibility="Collapsed"/>
                    
                    <TextBlock Text="BIOS" Style="{StaticResource SubTitle}"/>
                    <TextBlock Name="lblMobo" Text="..." Style="{StaticResource InfoText}"/>
                    <TextBlock Name="lblBiosDate" Text="..." FontSize="11" Foreground="#888" Margin="0,0,0,5"/>
                    <Button Name="btnUpdBios" Content="[MAJ BIOS]" Style="{StaticResource BtnAction}"/>

                    <Separator Background="#333" Margin="0,20"/>
                    
                    <TextBlock Text="OUTILS RAPIDES" Style="{StaticResource TitleText}"/>
                    <Button Name="btnWinget" Content="METTRE A JOUR LES APPS" Height="35" Background="#2b2b2b" Foreground="White" Margin="0,5"/>
                    <Button Name="btnRescan" Content="ACTUALISER L'ETAT (RE-SCAN)" Height="35" Background="#004444" Foreground="White" Margin="0,5"/>
                </StackPanel>
            </ScrollViewer>
        </Border>

        <Grid Grid.Column="1" Margin="30" Background="#121212">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="*"/> <RowDefinition Height="Auto"/> <RowDefinition Height="150"/>
            </Grid.RowDefinitions>

            <StackPanel Grid.Row="0">
                <TextBlock Text="MaTows OPTIMIZER V1.5.1" FontSize="34" FontWeight="Bold" Foreground="#00BFFF"/>
                <TextBlock Text="Optimisation Safe &amp; Detection Intelligente" Foreground="Gray" Margin="2,0,0,20"/>
            </StackPanel>

            <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,0,0,15">
                <Button Name="btnSelectAll" Content="MODE GAMER SUR (Recommande)" Width="220" Height="30" Background="#333" Foreground="White" BorderThickness="0" Margin="0,0,10,0"/>
                <Button Name="btnUnselectAll" Content="TOUT DECOCHER" Width="140" Height="30" Background="#333" Foreground="White" BorderThickness="0"/>
            </StackPanel>

            <TabControl Grid.Row="2" Background="#121212" BorderThickness="0">
                
                <TabItem Header=" SYSTEME ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <TextBlock Text="SECURITE &amp; NETTOYAGE" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Toujours recommande."/><CheckBox Name="chkRestore" IsChecked="True" Content="Creer un Point de Restauration (Action)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Vide les dossiers Temp."/><CheckBox Name="chkTemp" Content="Supprimer les Fichiers Temporaires (Action)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Limite l'envoi de donnees."/><CheckBox Name="chkTelem" Content="Bloquer la Telemetrie"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Gain de place sur SSD."/><CheckBox Name="chkHibern" Content="Desactiver l'Hibernation"/></StackPanel>
                            
                            <TextBlock Text="SERVICES" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Partage Wi-Fi."/><CheckBox Name="chkWifiSense" Content="Desactiver Wi-Fi Sense"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="ATTENTION : Ne pas cocher si vous imprimez."/><CheckBox Name="chkPrint" Content="Desactiver le service d'impression"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Peut aider le ping."/><CheckBox Name="chkDns" Content="Vider le cache DNS (Action)"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>

                <TabItem Header=" GAMING &amp; PERFS ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <TextBlock Text="OPTIMISATIONS JEUX" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="CPU a fond."/><CheckBox Name="chkUltPerf" Content="Activer 'Performances Ultimes'"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Reduit les lags."/><CheckBox Name="chkGameDVR" Content="Desactiver Xbox Game Bar &amp; DVR"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Registre uniquement."/><CheckBox Name="chkGaming" Content="Desactiver Overlay NVIDIA"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Priorite Windows."/><CheckBox Name="chkSysResp" Content="Priorite CPU aux jeux"/></StackPanel>

                            <TextBlock Text="SOURIS &amp; CLAVIER" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Raw Input."/><CheckBox Name="chkMouse" Content="Desactiver l'Acceleration Souris"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Anti-Popup."/><CheckBox Name="chkSticky" Content="Desactiver les Touches Remanentes"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Plus reactif."/><CheckBox Name="chkKeyboard" Content="Reduire la latence clavier"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>

                <TabItem Header=" LOOK &amp; WINDOWS 11 ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <Button Name="btnResetVisual" Content="REPARER ICONES NOIRES &amp; RESET VISUEL" Width="300" Height="30" Background="#442222" Foreground="White" HorizontalAlignment="Left" Margin="0,0,0,15" BorderThickness="1" BorderBrush="Red"/>
                            
                            <TextBlock Text="APPARENCE" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Enleve la fleche."/><CheckBox Name="chkArrows" Content="Enlever les fleches des raccourcis"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Mode Sombre."/><CheckBox Name="chkDark" Content="Forcer le Mode Sombre"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Fluidite."/><CheckBox Name="chkTrans" Content="Desactiver la transparence"/></StackPanel>
                            
                            <TextBlock Text="ERGONOMIE" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Menu classique."/><CheckBox Name="chkContextMenu" Content="Restaurer l'ancien Menu Clic-Droit"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Meteo."/><CheckBox Name="chkWidget" Content="Masquer les Widgets Meteo"/></StackPanel>
                            
                            <TextBlock Text="DIVERS" Style="{StaticResource TitleText}"/>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Securite."/><CheckBox Name="chkExt" Content="Afficher les extensions de fichiers"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Recherche Web."/><CheckBox Name="chkBing" Content="Supprimer Bing du menu Demarrer"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,5"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="IA."/><CheckBox Name="chkCopilot" Content="Desactiver Copilot"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>

            </TabControl>

            <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10">
                <Button Name="btnExit" Content="QUITTER" Width="100" Height="40" Background="#333" Foreground="White" Margin="10,0"/>
                <Button Name="btnApply" Content="APPLIQUER" Width="250" Height="40" Background="#00BFFF" Foreground="Black" FontWeight="Bold" FontSize="13"/>
            </StackPanel>

            <Border Grid.Row="4" Background="Black" BorderBrush="#333" BorderThickness="1" CornerRadius="5">
                <ScrollViewer Name="scrollLog" VerticalScrollBarVisibility="Auto">
                    <TextBlock Name="txtLog" Text="[LOGS] Chargement des modules..." Foreground="#00FF00" FontFamily="Consolas" FontSize="12" Padding="10" TextWrapping="Wrap"/>
                </ScrollViewer>
            </Border>
        </Grid>
    </Grid>
</Window>
"@

# 3. CHARGEMENT SECURISE
try {
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "ERREUR DE CHARGEMENT DE L'INTERFACE." -ForegroundColor Red
    Read-Host "Appuyez sur Entree..."
    Exit
}

# HELPER
function Open-Url($u) { Start-Process $u }
function Add-Log($msg) {
    $window.Dispatcher.Invoke({
        $tb = $window.FindName("txtLog")
        $sv = $window.FindName("scrollLog")
        if ($tb) {
            $tb.Text += "`n> " + $msg
            $sv.ScrollToEnd()
        }
    }, [System.Windows.Threading.DispatcherPriority]::Background)
    Start-Sleep -Milliseconds 20
}
function Get-ColorString($d) { if(!$d){return "Gray"}; $dd=(New-TimeSpan -Start $d -End (Get-Date)).Days; if($dd -lt 365){"#00FF00"} elseif($dd -lt 730){"#FFA500"} else{"#FF4444"} }

# --- DETECTION ETAT ---
function Set-Status($chkName, $isOptimized, $baseText) {
    $chk = $window.FindName($chkName)
    if ($chk) {
        if ($isOptimized) {
            $chk.IsChecked = $true
            $chk.Content = "$baseText [OK - DEJA FAIT]"
            $chk.Foreground = "#00FF00"
        } else {
            $chk.IsChecked = $false
            $chk.Content = "$baseText [NON ACTIF]"
            $chk.Foreground = "#CCCCCC"
        }
    }
}

function Set-Action($chkName, $baseText) {
    $chk = $window.FindName($chkName)
    if ($chk) {
        $chk.IsChecked = $false
        $chk.Content = "$baseText [ACTION - A FAIRE]"
        $chk.Foreground = "#00BFFF"
    }
}

function Detect-State {
    Add-Log "Analyse de l'etat du PC..."
    try {
        # ACTIONS
        Set-Action "chkRestore" "Creer un Point de Restauration"
        Set-Action "chkTemp" "Supprimer les Fichiers Temporaires"
        Set-Action "chkDns" "Vider le cache DNS"

        # ETATS
        $tel = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        Set-Status "chkTelem" ($tel.AllowTelemetry -eq 0) "Bloquer la Telemetrie"

        $hib = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -ErrorAction SilentlyContinue
        Set-Status "chkHibern" ($hib.HibernateEnabled -eq 0) "Desactiver l'Hibernation"

        $wifi = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -ErrorAction SilentlyContinue
        Set-Status "chkWifiSense" ($wifi.value -eq 0) "Desactiver Wi-Fi Sense"

        $spool = Get-Service "Spooler" -ErrorAction SilentlyContinue
        Set-Status "chkPrint" ($spool.StartType -eq "Disabled") "Desactiver Service Impression"

        $dvr = Get-ItemProperty "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        Set-Status "chkGameDVR" ($dvr.GameDVR_Enabled -eq 0) "Desactiver Xbox Game Bar"

        $nv = Get-ItemProperty "HKCU:\Software\NVIDIA Corporation\Global\ShadowPlay" -Name "Enable" -ErrorAction SilentlyContinue
        Set-Status "chkGaming" ($nv.Enable -eq 0) "Desactiver Overlay NVIDIA"

        $resp = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -ErrorAction SilentlyContinue
        Set-Status "chkSysResp" ($resp.SystemResponsiveness -eq 0) "Priorite CPU aux jeux"

        $mouse = Get-ItemProperty "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -ErrorAction SilentlyContinue
        Set-Status "chkMouse" ($mouse.MouseSpeed -eq "0") "Desactiver Accel. Souris"

        $kb = Get-ItemProperty "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -ErrorAction SilentlyContinue
        Set-Status "chkKeyboard" ($kb.KeyboardDelay -eq "0") "Reduire la latence clavier"

        $stk = Get-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -ErrorAction SilentlyContinue
        Set-Status "chkSticky" ($stk.Flags -eq "506") "Desactiver Touches Remanentes"

        $arr = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -ErrorAction SilentlyContinue
        Set-Status "chkArrows" ($arr -ne $null) "Enlever Fleches Raccourcis"

        $dark = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
        Set-Status "chkDark" ($dark.AppsUseLightTheme -eq 0) "Forcer Mode Sombre"

        $trans = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -ErrorAction SilentlyContinue
        Set-Status "chkTrans" ($trans.EnableTransparency -eq 0) "Desactiver Transparence"

        $ctx = Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
        Set-Status "chkContextMenu" ($ctx) "Menu Clic-Droit Classique"

        $snap = Get-ItemProperty "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -ErrorAction SilentlyContinue
        Set-Status "chkSnap" ($snap.WindowArrangementActive -eq "0") "Desactiver Snap Assist"

        $ext = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -ErrorAction SilentlyContinue
        Set-Status "chkExt" ($ext.HideFileExt -eq 0) "Afficher Extensions"

        $bing = Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -ErrorAction SilentlyContinue
        Set-Status "chkBing" ($bing.DisableSearchBoxSuggestions -eq 1) "Supprimer Bing Menu"

        $cop = Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
        Set-Status "chkCopilot" ($cop.TurnOffWindowsCopilot -eq 1) "Desactiver Copilot"

        $wid = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -ErrorAction SilentlyContinue
        Set-Status "chkWidget" ($wid.AllowNewsAndInterests -eq 0) "Masquer Widgets"

        Add-Log "Etat du PC synchronise."
    } catch { Add-Log "Erreur detection mineure (ignoree)." }
}

# --- INFOS ---
$lblPcType = $window.FindName("lblPcType"); $lblOS = $window.FindName("lblOS")
$lblCPU = $window.FindName("lblCPU"); $lblGPU = $window.FindName("lblGPU")
$lblRAM = $window.FindName("lblRAM"); $lblXMP = $window.FindName("lblXMP")
$lblCpuDate = $window.FindName("lblCpuDate"); $lblGpuDate = $window.FindName("lblGpuDate"); $lblBiosDate = $window.FindName("lblBiosDate")
$lblStorage = $window.FindName("lblStorage"); $lblMobo = $window.FindName("lblMobo")
$lblAudio = $window.FindName("lblAudio"); $lblNet = $window.FindName("lblNet")

# SYSTEM INFO
$os = Get-CimInstance Win32_OperatingSystem; if ($lblOS) { $lblOS.Text = $os.Caption }
try {
    $chassis = Get-CimInstance Win32_SystemEnclosure -ErrorAction SilentlyContinue
    if ($lblPcType) {
        if ($chassis -and (@(8, 9, 10, 11, 12, 14, 18, 21, 30, 31, 32) -contains $chassis.ChassisTypes[0])) { $lblPcType.Text = "LAPTOP (PORTABLE)"; $lblPcType.Foreground = "Orange" } else { $lblPcType.Text = "DESKTOP (TOUR)"; $lblPcType.Foreground = "#00FF00" }
    }
} catch { $lblPcType.Text = "PC" }

try {
    $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue | Sort FriendlyName; $txt = ""
    if ($disks) { foreach ($d in $disks) { $st = "SAIN"; if ($d.HealthStatus -ne "Healthy") { $st = "ATTENTION" }; $txt += "$($d.FriendlyName) [$st]`n" } } else { $txt = "Disques non detectes" }
    if ($lblStorage) { $lblStorage.Text = $txt }
} catch { $lblStorage.Text = "Erreur Disques" }

try { 
    $c = Get-CimInstance Win32_Processor; if ($lblCPU) { $lblCPU.Text = $c.Name }
    $cp = Get-CimInstance Win32_PnPSignedDriver | Where {$_.DeviceID -like "*Processor*"} | Select -First 1
    if ($cp -and $lblCpuDate) { try { $cd = [Management.ManagementDateTimeConverter]::ToDateTime($cp.DriverDate) } catch { $cd = Get-Date }; $lblCpuDate.Text = "Date Pilote: $($cd.ToShortDateString())"; $lblCpuDate.Foreground = Get-ColorString $cd }
} catch {} 
if ($window.FindName("btnUpdCPU")) { $window.FindName("btnUpdCPU").Add_Click({ Open-Url "https://www.google.com/search?q=drivers+$($c.Name)" }) }

try { 
    $g = Get-CimInstance Win32_VideoController | Select -First 1; if ($lblGPU) { $lblGPU.Text = $g.Name }
    if ($lblGpuDate) { try { $gd = [Management.ManagementDateTimeConverter]::ToDateTime($g.DriverDate) } catch { $gd = Get-Date }; $lblGpuDate.Text = "Date Pilote: $($gd.ToShortDateString())"; $lblGpuDate.Foreground = Get-ColorString $gd }
} catch {} 
if ($window.FindName("btnUpdGPU")) { $window.FindName("btnUpdGPU").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($g.Name)+download" }) }

try {
    $m = Get-CimInstance Win32_BaseBoard; $b = Get-CimInstance Win32_BIOS
    try { $bd = [Management.ManagementDateTimeConverter]::ToDateTime($b.ReleaseDate) } catch { $bd = Get-Date }
    $man = $m.Manufacturer; if ($man -match "Micro-Star") { $man = "MSI" }; if ($man -match "ASUSTeK") { $man = "ASUS" }
    if ($lblMobo) { $lblMobo.Text = "$man - $($m.Product)" }
    if ($lblBiosDate) { $lblBiosDate.Text = "Date Bios: $($bd.ToShortDateString())"; $lblBiosDate.Foreground = Get-ColorString $bd }
} catch {} 
if ($window.FindName("btnUpdBios")) { $window.FindName("btnUpdBios").Add_Click({ Open-Url "https://www.google.com/search?q=bios+update+$($man)+$($m.Product)" }) }

try {
    $rr = Get-CimInstance Win32_PhysicalMemory; $tot = 0; $xmp = $false
    foreach ($r in $rr) { $tot += $r.Capacity; if ($r.ConfiguredClockSpeed -lt $r.Speed) { $xmp = $true } }
    if ($lblRAM) { $lblRAM.Text = "$([math]::Round($tot/1GB)) Go RAM" }
    if ($lblXMP) { if ($xmp) { $lblXMP.Text = "XMP/EXPO : BRIDE !"; $lblXMP.Foreground = "#FF4444"; $window.FindName("btnTutoRAM").Visibility = "Visible" } else { $lblXMP.Text = "XMP/EXPO : OK"; $lblXMP.Foreground = "#00FF00" } }
} catch {} 
if ($window.FindName("btnTutoRAM")) { $window.FindName("btnTutoRAM").Add_Click({ Open-Url "https://www.google.com/search?q=enable+xmp+bios+$($man)+$($m.Product)" }) }

try { $a = Get-CimInstance Win32_SoundDevice -ErrorAction SilentlyContinue | Where Status -eq "OK" | Select -First 1; if ($lblAudio) { if ($a) { $lblAudio.Text = $a.Name } else { $lblAudio.Text = "Non detecte" } } } catch {}
if ($window.FindName("btnUpdAudio")) { $window.FindName("btnUpdAudio").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($a.Name)" }) }

try { $n = Get-CimInstance Win32_NetworkAdapter -ErrorAction SilentlyContinue | Where {$_.NetConnectionStatus -eq 2} | Select -First 1; if ($lblNet) { if ($n) { $lblNet.Text = $n.Name } else { $lblNet.Text = "Non connecte" } } } catch {}
if ($window.FindName("btnUpdNet")) { $window.FindName("btnUpdNet").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($n.Name)" }) }

# ACTIONS
if ($window.FindName("btnWinget")) { $window.FindName("btnWinget").Add_Click({ Start-Process cmd -ArgumentList "/k winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements" }) }
if ($window.FindName("btnRescan")) { $window.FindName("btnRescan").Add_Click({ Detect-State }) }

# BOUTON "MODE GAMER SUR" (SELECT ALL INTELLIGENT)
$window.FindName("btnSelectAll").Add_Click({ 
    # Coche uniquement les trucs surs (Pas d'hibernation, pas d'imprimante, pas de wifi)
    $safeList = @("chkTelem","chkGameDVR","chkGaming","chkSysResp","chkMouse","chkSticky","chkKeyboard","chkArrows","chkDark","chkTrans","chkContextMenu","chkSnap","chkWidget","chkExt","chkBing","chkCopilot")
    foreach ($n in $safeList) { 
        $c = $window.FindName($n)
        if ($c) { $c.IsChecked = $true }
    }
    # Coche aussi les actions one-shot
    $actions = @("chkRestore","chkTemp","chkDns")
    foreach ($a in $actions) { $window.FindName($a).IsChecked = $true }
})

$window.FindName("btnUnselectAll").Add_Click({ 
    $names = @("chkRestore","chkTemp","chkTelem","chkHibern","chkWifiSense","chkPrint","chkDns","chkThrot","chkUltPerf","chkGameDVR","chkGaming","chkSysResp","chkMouse","chkSticky","chkKeyboard","chkArrows","chkDark","chkTrans","chkContextMenu","chkSnap","chkWidget","chkExt","chkBing","chkCopilot")
    foreach ($n in $names) { $c = $window.FindName($n); if ($c) { $c.IsChecked = $false } }
})

$window.FindName("btnResetVisual").Add_Click({
    $names = @("chkArrows","chkDark","chkTrans","chkContextMenu","chkSnap","chkWidget","chkExt","chkBing","chkCopilot")
    foreach ($n in $names) { $c = $window.FindName($n); if ($c) { $c.IsChecked = $false } }
    
    # REPARER ICONES NOIRES IMMEDIATEMENT
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name explorer -ErrorAction SilentlyContinue
    Add-Log "Icones reparees & Reset visuel."
})

$window.FindName("btnExit").Add_Click({ $window.Close() })

# === APPLIQUER ===
$window.FindName("btnApply").Add_Click({
    $btn = $window.FindName("btnApply"); $btn.Content = "EN COURS..."
    $window.FindName("txtLog").Text = "--- TRAITEMENT ---"
    
    # SYSTEME
    if ($window.FindName("chkRestore").IsChecked) { Add-Log "Creation Point Restauration..."; Checkpoint-Computer -Description "MaTowsV1.6" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Add-Log "OK." }
    if ($window.FindName("chkTemp").IsChecked) { Add-Log "Nettoyage Temp..."; Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue; Add-Log "OK." }
    
    if ($window.FindName("chkTelem").IsChecked) { Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force } 
    else { Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1 -Type DWord -Force }

    if ($window.FindName("chkHibern").IsChecked) { powercfg /h off } else { powercfg /h on }

    if ($window.FindName("chkWifiSense").IsChecked) { New-ItemProperty "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null }
    else { New-ItemProperty "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null }

    if ($window.FindName("chkPrint").IsChecked) { Stop-Service "Spooler" -ErrorAction SilentlyContinue; Set-Service "Spooler" -StartupType Disabled }
    else { Set-Service "Spooler" -StartupType Automatic; Start-Service "Spooler" -ErrorAction SilentlyContinue }

    if ($window.FindName("chkDns").IsChecked) { Clear-DnsClientCache; Add-Log "DNS Flush." }
    
    # GAMING
    if ($window.FindName("chkUltPerf").IsChecked) { powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null }
    
    if ($window.FindName("chkGameDVR").IsChecked) { 
        New-ItemProperty "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; 
        New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null;
    } else {
        Set-ItemProperty "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -Type DWord -Force
        Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 1 -Type DWord -Force
    }

    if ($window.FindName("chkGaming").IsChecked) {
        $nKey = "HKCU:\Software\NVIDIA Corporation\Global\ShadowPlay"; if (-not (Test-Path $nKey)) { New-Item $nKey -Force | Out-Null }; Set-ItemProperty $nKey "Enable" 0 -Type DWord -Force
    } else {
        $nKey = "HKCU:\Software\NVIDIA Corporation\Global\ShadowPlay"; if (Test-Path $nKey) { Set-ItemProperty $nKey "Enable" 1 -Type DWord -Force }
    }

    if ($window.FindName("chkSysResp").IsChecked) { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force }
    else { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 20 -Type DWord -Force }
    
    # INPUT
    if ($window.FindName("chkMouse").IsChecked) { Set-ItemProperty "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force }
    else { Set-ItemProperty "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Force }

    if ($window.FindName("chkSticky").IsChecked) { Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Force }
    else { Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "510" -Force }

    if ($window.FindName("chkKeyboard").IsChecked) { Set-ItemProperty "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0 -Type String -Force }
    else { Set-ItemProperty "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 1 -Type String -Force }

    # VISUEL
    if ($window.FindName("chkArrows").IsChecked) { 
        $iconKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
        if (-not (Test-Path $iconKey)) { New-Item $iconKey -Force | Out-Null }
        # FIX CARRE NOIR: Utiliser une virgule au lieu d'un tiret pour l'index
        Set-ItemProperty $iconKey -Name "29" -Value "%windir%\System32\shell32.dll,50" -Force
    } else {
        Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -ErrorAction SilentlyContinue
    }

    if ($window.FindName("chkDark").IsChecked) { 
        Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
        Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
    } else {
        Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1 -Type DWord -Force
        Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1 -Type DWord -Force
    }

    if ($window.FindName("chkTrans").IsChecked) { Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force }
    else { Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1 -Type DWord -Force }

    $kMenu = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
    if ($window.FindName("chkContextMenu").IsChecked) {
        if (-not (Test-Path "$kMenu\InprocServer32")) { New-Item "$kMenu\InprocServer32" -Force | Out-Null }
        Set-ItemProperty "$kMenu\InprocServer32" -Name "(default)" -Value "" -Force
    } else {
        Remove-Item $kMenu -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($window.FindName("chkSnap").IsChecked) { Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -Value 0 -Type String -Force }
    else { Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -Value 1 -Type String -Force }
    
    if ($window.FindName("chkExt").IsChecked) { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force }
    else { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1 -Force }

    if ($window.FindName("chkBing").IsChecked) { Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type Dword -Force }
    else { Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 0 -Type Dword -Force }

    if ($window.FindName("chkCopilot").IsChecked) { New-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null }
    else { Remove-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue }

    if ($window.FindName("chkWidget").IsChecked) { New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null }
    else { Remove-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -ErrorAction SilentlyContinue }
    
    Stop-Process -Name explorer -ErrorAction SilentlyContinue

    Add-Log "--- TERMINE ! ---"
    Detect-State
    $btn.Content = "TERMINÉ"
    
    $res = [System.Windows.Forms.MessageBox]::Show("Optimisation terminee !`n`nRedemarrer maintenant ?", "MaTows Optimizer", "YesNo", "Question")
    if ($res -eq "Yes") { Restart-Computer -Force }
})

$window.Add_Loaded({ Detect-State })
try { $window.ShowDialog() | Out-Null } catch { Write-Host "Erreur : $_"; Read-Host "..." }