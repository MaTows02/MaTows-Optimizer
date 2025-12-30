<#
    ===========================================================================
    MATOWS OPTIMIZER - V1.1
    ===========================================================================
#>

# 0. GESTION DES ERREURS
Trap {
    Write-Host "`n[ERREUR CRITIQUE DETECTEE]" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Ligne : $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Yellow
    Read-Host "Appuyez sur ENTREE pour fermer la fenetre..."
    Exit
}

# 1. SETUP & MODE SECURISE
if ($host.Runspace.ApartmentState -ne 'STA') {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -PassThru
    Exit
}

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. INTERFACE XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MaTows Optimizer - V1.1" Height="950" Width="1280" 
        WindowStartupLocation="CenterScreen" Background="#181818" Foreground="White">

    <Window.Resources>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/> <Setter Property="FontSize" Value="14"/> <Setter Property="Cursor" Value="Hand"/> <Setter Property="Margin" Value="5,2"/>
        </Style>
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#252526"/> <Setter Property="Foreground" Value="White"/> <Setter Property="BorderBrush" Value="#00BFFF"/> <Setter Property="FontSize" Value="12"/> <Setter Property="Padding" Value="10"/> <Setter Property="MaxWidth" Value="450"/>
        </Style>
        <Style x:Key="HelpIcon" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#00BFFF"/> <Setter Property="FontWeight" Value="Bold"/> <Setter Property="FontSize" Value="15"/> <Setter Property="Margin" Value="0,0,10,0"/> <Setter Property="Cursor" Value="Help"/> <Setter Property="Text" Value="(?)"/> <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style x:Key="BtnUpdate" TargetType="Button">
            <Setter Property="Background" Value="#333"/> <Setter Property="Foreground" Value="#00BFFF"/> <Setter Property="FontSize" Value="11"/> <Setter Property="Padding" Value="8,2"/> <Setter Property="Margin" Value="5,0"/> <Setter Property="BorderThickness" Value="0"/> <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" BorderThickness="1,1,1,0" BorderBrush="#444" Margin="2,0">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="15,10"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#00BFFF"/> <Setter Property="Foreground" Value="Black"/> <Setter Property="FontWeight" Value="Bold"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#2d2d30"/> <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions> <ColumnDefinition Width="420"/> <ColumnDefinition Width="*"/> </Grid.ColumnDefinitions>

        <Border Grid.Column="0" Background="#202020" BorderBrush="#444" BorderThickness="0,0,1,0">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <StackPanel Margin="20">
                    <Border BorderBrush="Gray" BorderThickness="1" Padding="15" Margin="0,0,0,20" CornerRadius="5">
                        <StackPanel>
                            <TextBlock Text="TYPE D'ORDINATEUR :" FontSize="12" Foreground="Gray"/>
                            <TextBlock Name="lblPcType" Text="ANALYSE..." FontSize="22" FontWeight="Bold" Foreground="White"/>
                            <StackPanel Name="pnlBattery" Visibility="Collapsed" Margin="0,10,0,0">
                                <Separator Background="#444" Margin="0,5"/>
                                <TextBlock Text="SANTE BATTERIE :" FontSize="12" Foreground="Gray" Margin="0,5,0,0"/>
                                <TextBlock Name="lblBatHealth" Text="..." FontSize="20" FontWeight="Bold" Foreground="White"/>
                                <TextBlock Name="lblBatDetail" Text="..." FontSize="11" Foreground="Silver" TextWrapping="Wrap"/>
                            </StackPanel>
                        </StackPanel>
                    </Border>

                    <TextBlock Text="SCAN MATERIEL" FontWeight="Bold" FontSize="18" Foreground="#00BFFF" Margin="0,0,0,20"/>
                    
                    <TextBlock Text="STOCKAGE (DISQUES)" Foreground="Gray" FontSize="11"/>
                    <TextBlock Name="lblStorage" Text="Analyse..." TextWrapping="Wrap" FontSize="13" FontWeight="Bold" Margin="0,0,0,15"/>

                    <TextBlock Text="PROCESSEUR (CPU)" Foreground="Gray" FontSize="11"/>
                    <TextBlock Name="lblCPU" Text="..." TextWrapping="Wrap" FontSize="13" FontWeight="Bold" Margin="0,0,0,5"/>
                    <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><TextBlock Name="lblCpuDate" Text="..." FontSize="12"/><Button Name="btnUpdCPU" Content="[MAJ CPU]" Style="{StaticResource BtnUpdate}"/></StackPanel>

                    <TextBlock Text="CARTE GRAPHIQUE" Foreground="Gray" FontSize="11"/>
                    <TextBlock Name="lblGPU" Text="..." TextWrapping="Wrap" FontSize="13" Margin="0,0,0,5"/>
                    <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><TextBlock Name="lblGpuDate" Text="..." FontSize="12"/><Button Name="btnUpdGPU" Content="[TELECHARGER]" Style="{StaticResource BtnUpdate}"/></StackPanel>

                    <TextBlock Text="CARTE MERE &amp; BIOS" Foreground="Gray" FontSize="11"/>
                    <TextBlock Name="lblMobo" Text="..." TextWrapping="Wrap" FontSize="13" Margin="0,0,0,5"/>
                    <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><TextBlock Name="lblBiosDate" Text="..." FontSize="12"/><Button Name="btnUpdBios" Content="[MAJ BIOS]" Style="{StaticResource BtnUpdate}"/></StackPanel>

                    <TextBlock Text="RAM &amp; FREQUENCES" Foreground="Gray" FontSize="11"/>
                    <TextBlock Name="lblRAMTotal" Text="..." FontWeight="Bold" FontSize="14" Margin="0,0,0,5"/>
                    <TextBlock Name="lblXMPStatus" Text="ANALYSE..." FontSize="13" FontWeight="Bold" Margin="0,0,0,5"/>
                    <TextBlock Name="lblRAMDetail" Text="..." FontSize="12" Foreground="#E0E0E0" TextWrapping="Wrap"/>
                    <Button Name="btnTutoRAM" Content="[ACTIVER XMP/EXPO]" Style="{StaticResource BtnUpdate}" Visibility="Collapsed" HorizontalAlignment="Left" Margin="0,10,0,15"/>

                    <TextBlock Text="RESEAU &amp; AUDIO" Foreground="Gray" FontSize="11" Margin="0,10,0,0"/>
                    <TextBlock Name="lblNet" Text="..." FontSize="12" Margin="0,0,0,2"/>
                    <Button Name="btnUpdNet" Content="[MAJ RESEAU]" Style="{StaticResource BtnUpdate}" HorizontalAlignment="Left" Margin="0,0,0,5"/>
                    <TextBlock Name="lblAudio" Text="..." FontSize="12" Margin="0,5,0,2"/>
                    <Button Name="btnUpdAudio" Content="[MAJ AUDIO]" Style="{StaticResource BtnUpdate}" HorizontalAlignment="Left"/>

                    <TextBlock Text="OUTILS SYSTEME" Foreground="Gray" FontSize="11" Margin="0,20,0,5"/>
                    <Button Name="btnWinget" Content="[LANCER WINGET UPDATE]" Height="30" Background="#444" Foreground="White" BorderThickness="0"/>
                </StackPanel>
            </ScrollViewer>
        </Border>

        <Grid Grid.Column="1" Margin="25" Background="#181818">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="*"/> <RowDefinition Height="Auto"/> <RowDefinition Height="150"/>
            </Grid.RowDefinitions>

            <StackPanel Grid.Row="0">
                <TextBlock Text="MaTows OPTIMIZER" FontSize="32" FontWeight="Bold" Foreground="#00BFFF"/>
                <TextBlock Text="Passez la souris sur (?) pour voir l'impact." Foreground="Gray" Margin="0,0,0,10"/>
            </StackPanel>

            <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,0,0,15">
                <Button Name="btnSelectAll" Content="TOUT COCHER (AUTO)" Width="150" Height="25" Background="#444" Foreground="White" Margin="0,0,10,0" BorderThickness="0"/>
                <Button Name="btnUnselectAll" Content="TOUT DECOCHER" Width="120" Height="25" Background="#444" Foreground="White" BorderThickness="0"/>
            </StackPanel>

            <TabControl Grid.Row="2" Background="#181818" BorderThickness="0">
                <TabItem Header=" GENERAL ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Background="#181818">
                        <StackPanel Margin="10">
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Cree un point de restauration."/><CheckBox Name="chkRestore" IsChecked="True" Content="Creer Point de Restauration (Recommande)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Supprime les fichiers temporaires."/><CheckBox Name="chkTemp" Content="Nettoyer Fichiers Temporaires"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Bloque l'envoi de donnees a Microsoft."/><CheckBox Name="chkTelem" Content="Bloquer Telemetrie &amp; Mouchards"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Desactive hiberfil.sys (Gain place)."/><CheckBox Name="chkHibern" Content="Desactiver Hibernation (Gain place)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Empeche le partage cles Wi-Fi."/><CheckBox Name="chkWifiSense" Content="Desactiver Wi-Fi Sense"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Arrete le service d'impression."/><CheckBox Name="chkPrint" Content="Desactiver Service Imprimante"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                <TabItem Header=" COMPETITIF ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Background="#181818">
                        <StackPanel Margin="10">
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Opti Discord, Steam, Epic, Nvidia (Safe)."/><CheckBox Name="chkGaming" Content="Optimisation Gaming (Discord/Nvidia/Launchers)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Desactive Xbox Game Bar."/><CheckBox Name="chkGameDVR" Content="Desactiver GameDVR &amp; Xbox Bar"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Force CPU 100%."/><CheckBox Name="chkUltPerf" Content="Plan 'Performances Ultimes'"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Retire la limite reseau Windows."/><CheckBox Name="chkThrot" Content="Optimiser Reseau (Throttling)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Raw Input souris."/><CheckBox Name="chkMouse" Content="Desactiver Acceleration Souris"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Desactive Shift 5x."/><CheckBox Name="chkSticky" Content="Desactiver Sticky Keys"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Priorite CPU aux jeux."/><CheckBox Name="chkSysResp" Content="Optimiser la Reactivite (SystemProfile)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Arrete l'indexation de fichiers."/><CheckBox Name="chkIndex" Content="Desactiver Indexation Recherche"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Vide cache DNS."/><CheckBox Name="chkDns" Content="Vider le cache DNS"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                <TabItem Header=" INTERFACE ">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Background="#181818">
                        <StackPanel Margin="10">
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Affiche .exe, .bat."/><CheckBox Name="chkExt" Content="Afficher Extensions de fichiers"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Retire Bing du menu Demarrer."/><CheckBox Name="chkBing" Content="Supprimer Recherche Bing (Menu)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Bloque applis Windows Store en fond."/><CheckBox Name="chkBgApps" Content="Stopper applis en arriere-plan"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Desactive IA Copilot."/><CheckBox Name="chkCopilot" Content="Desactiver Copilot (IA)"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,8"><TextBlock Style="{StaticResource HelpIcon}" ToolTip="Desactive Widgets Meteo."/><CheckBox Name="chkWidget" Content="Desactiver Widgets (Meteo/News)"/></StackPanel>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
            </TabControl>

            <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,5,0,5">
                <Button Name="btnExit" Content="QUITTER" Width="100" Height="45" Margin="10" Background="#333" Foreground="White"/>
                <Button Name="btnApply" Content="LANCER L'OPTIMISATION" Width="220" Height="45" Margin="10" Background="#00BFFF" Foreground="Black" FontWeight="Bold" FontSize="14"/>
            </StackPanel>

            <Border Grid.Row="4" Background="Black" BorderBrush="#00BFFF" BorderThickness="1" Margin="0,5,0,0">
                <ScrollViewer Name="scrollLog" VerticalScrollBarVisibility="Auto">
                    <TextBlock Name="txtLog" Text="[LOGS] Pret." Foreground="#00FF00" FontFamily="Consolas" FontSize="14" Padding="5" TextWrapping="Wrap"/>
                </ScrollViewer>
            </Border>
        </Grid>
    </Grid>
</Window>
"@

# 3. CHARGEMENT
try {
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "ERREUR DE CHARGEMENT XAML (Interface) :" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Read-Host "Pressez Entree..."
    Exit
}

# Fonctions Helpers
function Get-ColorString($d) { if(!$d){return "Gray"}; $dd=(New-TimeSpan -Start $d -End (Get-Date)).Days; if($dd -lt 365){"#00FF00"} elseif($dd -lt 730){"#FFA500"} else{"#FF4444"} }
function Open-Url($u) { Start-Process $u }

# FONCTION LOG VISUELLE (FORCE LE REFRESH)
function Add-Log($msg) {
    $window.Dispatcher.Invoke({
        $tb = $window.FindName("txtLog")
        $sv = $window.FindName("scrollLog")
        $tb.Text += "`n> " + $msg
        $sv.ScrollToEnd()
    }, [System.Windows.Threading.DispatcherPriority]::Background)
    Start-Sleep -Milliseconds 100 
}

# Mapping UI
$lblPcType = $window.FindName("lblPcType"); $pnlBattery = $window.FindName("pnlBattery"); $lblBatHealth = $window.FindName("lblBatHealth"); $lblBatDetail = $window.FindName("lblBatDetail")
$lblStorage = $window.FindName("lblStorage"); $lblMobo = $window.FindName("lblMobo"); $lblBiosDate = $window.FindName("lblBiosDate")
$lblCPU = $window.FindName("lblCPU"); $lblCpuDate = $window.FindName("lblCpuDate"); $lblGPU = $window.FindName("lblGPU"); $lblGpuDate = $window.FindName("lblGpuDate")
$lblAudio = $window.FindName("lblAudio"); $lblRAMTotal = $window.FindName("lblRAMTotal"); $lblRAMDetail = $window.FindName("lblRAMDetail"); $lblXMPStatus = $window.FindName("lblXMPStatus")
$lblNet = $window.FindName("lblNet")

# 0. DETECTION LAPTOP
try {
    $chassis = Get-CimInstance Win32_SystemEnclosure -ErrorAction SilentlyContinue
    if ($chassis) { $isLaptop = @(8, 9, 10, 11, 12, 14, 18, 21, 30, 31, 32) -contains $chassis.ChassisTypes[0] } else { $isLaptop = $false }
} catch { $isLaptop = $false }

if ($isLaptop) {
    $lblPcType.Text = "LAPTOP (PORTABLE)"; $lblPcType.Foreground = "Orange"
    $window.FindName("chkUltPerf").Foreground = "Orange"; $window.FindName("chkHibern").Foreground = "Orange"
    try {
        $pnlBattery.Visibility = "Visible"
        $bs = Get-CimInstance -Namespace root/wmi -ClassName BatteryStaticData -ErrorAction Stop | Select -First 1
        $bf = Get-CimInstance -Namespace root/wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select -First 1
        if ($bs.DesignedCapacity -gt 0) {
            $h = [math]::Round(($bf.FullChargedCapacity / $bs.DesignedCapacity) * 100, 1)
            $lblBatHealth.Text = "$h %"; $lblBatDetail.Text = "Capacite: $($bf.FullChargedCapacity) / Usine: $($bs.DesignedCapacity)"
            if ($h -gt 80) { $lblBatHealth.Foreground = "#00FF00" } elseif ($h -gt 50) { $lblBatHealth.Foreground = "Orange" } else { $lblBatHealth.Foreground = "#FF4444" }
        } else { $lblBatHealth.Text = "Inconnu"; $lblBatDetail.Text = "Info non dispo" }
    } catch { $lblBatHealth.Text = "N/A"; $lblBatDetail.Text = "Non detectee" }
} else {
    $lblPcType.Text = "DESKTOP (BUREAU)"; $lblPcType.Foreground = "#00FF00"
}

# 1. STOCKAGE
try {
    $disks = Get-PhysicalDisk -ErrorAction Stop | Sort FriendlyName
    $diskText = ""
    foreach ($d in $disks) {
        $st = "SAIN"; if ($d.HealthStatus -ne "Healthy") { $st = "ATTENTION" }
        $diskText += "$($d.FriendlyName) : $st`n"
    }
    $lblStorage.Text = $diskText
} catch { $lblStorage.Text = "Erreur disques" }

# 2. CPU
try {
    $c = Get-CimInstance Win32_Processor -ErrorAction Stop
    $lblCPU.Text = $c.Name
    $cp = Get-CimInstance Win32_PnPSignedDriver | Where {$_.DeviceID -like "*Processor*"} | Select -First 1
    if ($cp) { try { $cd = [Management.ManagementDateTimeConverter]::ToDateTime($cp.DriverDate) } catch { $cd = Get-Date }; $lblCpuDate.Text = "Pilote: $($cd.ToShortDateString())"; $lblCpuDate.Foreground = Get-ColorString $cd }
    $window.FindName("btnUpdCPU").Add_Click({ Open-Url "https://www.google.com/search?q=drivers+$($c.Name)" })
} catch { $lblCPU.Text = "Inconnu" }

# 3. MOBO
try {
    $m = Get-CimInstance Win32_BaseBoard -ErrorAction Stop; $b = Get-CimInstance Win32_BIOS
    try { $bd = [Management.ManagementDateTimeConverter]::ToDateTime($b.ReleaseDate) } catch { $bd = Get-Date }
    $man = $m.Manufacturer; if ($man -match "Micro-Star") { $man = "MSI" }; if ($man -match "ASUSTeK") { $man = "ASUS" }
    $lblMobo.Text = "$man - $($m.Product)"; $lblBiosDate.Text = "Bios: $($bd.ToShortDateString())"; $lblBiosDate.Foreground = Get-ColorString $bd
    $window.FindName("btnUpdBios").Add_Click({ Open-Url "https://www.google.com/search?q=bios+update+$($man)+$($m.Product)" })
} catch { $lblMobo.Text = "Inconnue" }

# 4. GPU
try {
    $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Select -First 1
    try { $gd = [Management.ManagementDateTimeConverter]::ToDateTime($g.DriverDate) } catch { $gd = Get-Date }; $lblGPU.Text = $g.Name; $lblGpuDate.Text = "Pilote: $($gd.ToShortDateString())"; $lblGpuDate.Foreground = Get-ColorString $gd
    $window.FindName("btnUpdGPU").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($g.Name)+download" })
} catch { $lblGPU.Text = "Inconnu" }

# 5. AUDIO
try {
    $a = Get-CimInstance Win32_SoundDevice -ErrorAction SilentlyContinue | Where Status -eq "OK" | Sort Manufacturer | Select -First 1
    if ($a) { $lblAudio.Text = $a.Name; $window.FindName("btnUpdAudio").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($a.Name)" }) } else { $lblAudio.Text = "Non detecte" }
} catch { $lblAudio.Text = "Erreur" }

# 6. RAM
try {
    $rr = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
    $tot = 0; $txt = ""; $xmp = $false
    foreach ($r in $rr) {
        $tot += $r.Capacity; $s = $r.Speed; $cs = $r.ConfiguredClockSpeed; $loc = $r.DeviceLocator
        $txt += "Slot $loc : $cs MHz (Max: $s)`n"; if ($cs -lt $s) { $xmp = $true }
    }
    $lblRAMTotal.Text = "$([math]::Round($tot/1GB)) Go RAM"; $lblRAMDetail.Text = $txt
    if ($xmp) { $lblXMPStatus.Text = "XMP BRIDE !"; $lblXMPStatus.Foreground = "#FF4444"; $window.FindName("btnTutoRAM").Visibility = "Visible" } else { $lblXMPStatus.Text = "XMP OPTIMAL"; $lblXMPStatus.Foreground = "#00FF00" }
    $window.FindName("btnTutoRAM").Add_Click({ Open-Url "https://www.youtube.com/results?search_query=enable+xmp+bios+$($man)+$($m.Product)" })
} catch { $lblRAMTotal.Text = "Erreur" }

# 7. NET
try {
    $n = Get-CimInstance Win32_NetworkAdapter -ErrorAction SilentlyContinue | Where {$_.NetConnectionStatus -eq 2} | Select -First 1
    if ($n) { $lblNet.Text = $n.Name; $window.FindName("btnUpdNet").Add_Click({ Open-Url "https://www.google.com/search?q=driver+$($n.Name)" }) } else { $lblNet.Text = "Non connecte" }
} catch { $lblNet.Text = "Erreur" }

# BOUTONS
$listBoxes = @("chkRestore","chkTemp","chkTelem","chkHibern","chkWifiSense","chkPrint","chkGaming","chkGameDVR","chkUltPerf","chkThrot","chkMouse","chkSticky","chkSysResp","chkIndex","chkDns","chkExt","chkBing","chkBgApps","chkCopilot","chkWidget")

$window.FindName("btnWinget").Add_Click({ Start-Process cmd -ArgumentList "/k winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements" })
$window.FindName("btnSelectAll").Add_Click({ foreach ($n in $listBoxes) { if ($isLaptop -and ($n -eq "chkUltPerf" -or $n -eq "chkHibern")) { continue }; $window.FindName($n).IsChecked = $true } })
$window.FindName("btnUnselectAll").Add_Click({ foreach ($n in $listBoxes) { $window.FindName($n).IsChecked = $false } })
$window.FindName("btnExit").Add_Click({ $window.Close() })

# APPLY
$window.FindName("btnApply").Add_Click({
    $btn = $window.FindName("btnApply"); $btn.Content = "EN COURS..."
    $window.FindName("txtLog").Text = "--- DEBUT OPTIMISATION ---"
    
    if ($window.FindName("chkRestore").IsChecked) { Add-Log "Creation Point Restauration..."; Checkpoint-Computer -Description "MaTowsOpti" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Add-Log "OK." }
    if ($window.FindName("chkTemp").IsChecked) { Add-Log "Suppression Fichiers Temp..."; Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue; Add-Log "OK." }
    if ($window.FindName("chkTelem").IsChecked) { Add-Log "Desactivation Telemetrie..."; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force; Add-Log "OK." }
    if ($window.FindName("chkHibern").IsChecked) { Add-Log "Arret Hibernation..."; powercfg /h off; Add-Log "OK." }
    if ($window.FindName("chkWifiSense").IsChecked) { Add-Log "Securisation Wifi..."; New-ItemProperty "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; Add-Log "OK." }
    if ($window.FindName("chkPrint").IsChecked) { Add-Log "Arret Spooler..."; Stop-Service "Spooler" -ErrorAction SilentlyContinue; Set-Service "Spooler" -StartupType Disabled; Add-Log "OK." }
    
    # --- SECTION GAMING (SAFE) ---
    if ($window.FindName("chkGaming").IsChecked) {
        Add-Log "Opti Gaming (Safe Mode)..."
        
        # Discord : Disable Hardware Acceleration in Config (No kill process)
        $discordPath = "$env:APPDATA\discord\settings.json"
        if (Test-Path $discordPath) {
            try {
                $json = Get-Content $discordPath -Raw
                if ($json -match '"enableHardwareAcceleration":\s*true') {
                    $json = $json -replace '"enableHardwareAcceleration":\s*true', '"enableHardwareAcceleration": false'
                    $json = $json -replace '"enableOverlay":\s*true', '"enableOverlay": false'
                    Set-Content $discordPath $json
                    Add-Log "Discord Config OK."
                }
            } catch { Add-Log "Discord skip." }
        }

        # NVIDIA : Disable ShadowPlay/Overlay via Registry ONLY (No service kill)
        $nvKey = "HKCU:\Software\NVIDIA Corporation\Global\ShadowPlay"
        if (-not (Test-Path $nvKey)) { New-Item -Path $nvKey -Force | Out-Null }
        Set-ItemProperty -Path $nvKey -Name "Enable" -Value 0 -Type DWord -Force
        Add-Log "Nvidia Overlay Reg OK."

        # Launchers : Remove from startup
        $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        Remove-ItemProperty -Path $runKey -Name "Steam" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $runKey -Name "EpicGamesLauncher" -ErrorAction SilentlyContinue
        Add-Log "Steam/Epic Startup OFF."
    }

    if ($window.FindName("chkGameDVR").IsChecked) { 
        Add-Log "Arret GameDVR..."; 
        New-ItemProperty "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; 
        New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null;
        Add-Log "OK." 
    }

    if ($window.FindName("chkUltPerf").IsChecked) { Add-Log "Plan Performance..."; powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null; Add-Log "OK." }
    if ($window.FindName("chkThrot").IsChecked) { Add-Log "Reseau Throttling..."; Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force; Add-Log "OK." }
    if ($window.FindName("chkMouse").IsChecked) { Add-Log "Souris Raw Input..."; Set-ItemProperty "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force; Add-Log "OK." }
    if ($window.FindName("chkSticky").IsChecked) { Add-Log "Arret StickyKeys..."; Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Force; Add-Log "OK." }
    if ($window.FindName("chkSysResp").IsChecked) { Add-Log "System Responsiveness..."; Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force; Add-Log "OK." }
    if ($window.FindName("chkIndex").IsChecked) { Add-Log "Arret Indexation..."; Stop-Service "WSearch" -ErrorAction SilentlyContinue; Set-Service "WSearch" -StartupType Disabled; Add-Log "OK." }
    if ($window.FindName("chkDns").IsChecked) { Add-Log "Flush DNS..."; Clear-DnsClientCache; Add-Log "OK." }
    if ($window.FindName("chkExt").IsChecked) { Add-Log "Affichage Extensions..."; Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force; Add-Log "OK." }
    if ($window.FindName("chkBing").IsChecked) { Add-Log "Suppression Bing..."; Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type Dword -Force; Add-Log "OK." }
    if ($window.FindName("chkBgApps").IsChecked) { Add-Log "Arret Apps Arriere-plan..."; New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; Add-Log "OK." }
    if ($window.FindName("chkCopilot").IsChecked) { Add-Log "Arret Copilot..."; New-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; Add-Log "OK." }
    if ($window.FindName("chkWidget").IsChecked) { Add-Log "Arret Widgets..."; New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null; Add-Log "OK." }

    Add-Log "--- TERMINÉ ! ---"
    $btn.Content = "LANCER L'OPTIMISATION"
    
    $res = [System.Windows.Forms.MessageBox]::Show("Optimisation terminee !`nVoulez-vous redemarrer maintenant ?", "MaTows Optimizer", "YesNo", "Question")
    if ($res -eq "Yes") { Restart-Computer -Force }
})

try { $window.ShowDialog() | Out-Null } catch { 
    Write-Host "Erreur : $_" 
    Read-Host "Pause..."
}