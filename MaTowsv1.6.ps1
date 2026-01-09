<#
    ===========================================================================
    MATOWS UTILITY - V1.6 (RESTORE POINT + FORCE RESTART)
    ===========================================================================
#>

# 1. AUTO-ADMIN
$Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object System.Security.Principal.WindowsPrincipal($Identity)
if (!($Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. SETUP
$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# 3. INTERFACE GRAPHIQUE
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MaTows Utility - v1.6" Height="950" Width="1600" 
        WindowStartupLocation="CenterScreen" Background="#121212" Foreground="White">

    <Window.Resources>
        <SolidColorBrush x:Key="Accent" Color="#007ACC"/>
        
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#1F1F1F"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#007ACC"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="MaxWidth" Value="400"/>
            <Setter Property="ContentTemplate">
                <Setter.Value>
                    <DataTemplate>
                        <TextBlock Text="{Binding}" TextWrapping="Wrap"/>
                    </DataTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#DDDDDD"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,4"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>

        <Style x:Key="Toggle" TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal">
                            <Grid Width="40" Height="20">
                                <Border x:Name="Border" Background="#333" CornerRadius="10" BorderThickness="1" BorderBrush="#555"/>
                                <Ellipse x:Name="Dot" Fill="White" Width="14" Height="14" HorizontalAlignment="Left" Margin="3,0,0,0"/>
                            </Grid>
                            <ContentPresenter Margin="10,0,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#007ACC"/>
                                <Setter TargetName="Border" Property="BorderBrush" Value="#007ACC"/>
                                <Setter TargetName="Dot" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="Dot" Property="Margin" Value="0,0,3,0"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="Header" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#007ACC"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Margin" Value="0,15,0,10"/>
            <Setter Property="TextDecorations" Value="Underline"/>
        </Style>

        <Style x:Key="Tip" TargetType="TextBlock">
            <Setter Property="Foreground" Value="Gray"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="8,2,0,0"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Text" Value="(?)"/>
            <Setter Property="Cursor" Value="Help"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="#007ACC"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#2D2D30"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" Background="{TemplateBinding Background}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#404040"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#007ACC"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="DashCard" TargetType="Border">
            <Setter Property="Background" Value="#1E1E1E"/>
            <Setter Property="CornerRadius" Value="8"/>
            <Setter Property="Padding" Value="20"/>
            <Setter Property="Margin" Value="0,0,0,15"/>
            <Setter Property="BorderBrush" Value="#333"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
        <Style x:Key="DashTitle" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#888"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Margin" Value="0,0,0,5"/>
        </Style>
        <Style x:Key="DashValue" TargetType="TextBlock">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="18"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
        </Style>
        <Style x:Key="LinkBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#00A4EF"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="HorizontalAlignment" Value="Left"/>
            <Setter Property="Margin" Value="0,5,0,0"/>
            <Setter Property="Padding" Value="0"/>
             <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <ContentPresenter/>
                        <ControlTemplate.Triggers>
                             <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="120"/>
        </Grid.RowDefinitions>

        <Border Background="#1F1F1F" Padding="20" BorderBrush="#333" BorderThickness="0,0,0,1">
            <Grid>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <TextBlock Text="MaTows" FontSize="28" FontWeight="Bold" Foreground="White"/>
                    <TextBlock Text=" UTILITY" FontSize="28" FontWeight="Light" Foreground="#AAA"/>
                    <TextBlock Text=" v1.6" FontSize="14" Foreground="#007ACC" VerticalAlignment="Bottom" Margin="8,0,0,6"/>
                </StackPanel>
                <Button Name="btnScanPC" Content="ACTUALISER ETAT SYSTEME" HorizontalAlignment="Right" Background="#007ACC" FontWeight="Bold"/>
            </Grid>
        </Border>

        <TabControl Grid.Row="1" Background="Transparent" BorderThickness="0" Margin="10,20,10,0">
            <TabControl.Resources>
                <Style TargetType="TabItem">
                    <Setter Property="FontSize" Value="15"/>
                    <Setter Property="Foreground" Value="#888"/>
                    <Setter Property="FontWeight" Value="SemiBold"/>
                    <Setter Property="Background" Value="Transparent"/>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="TabItem">
                                <Border Name="Border" BorderThickness="0,0,0,3" BorderBrush="Transparent" Margin="20,0" Padding="15,10">
                                    <ContentPresenter ContentSource="Header"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsSelected" Value="True">
                                        <Setter TargetName="Border" Property="BorderBrush" Value="#007ACC"/>
                                        <Setter Property="Foreground" Value="White"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Style>
            </TabControl.Resources>

            <TabItem Header="MON PC">
                <Grid Margin="20">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="TYPE &amp; SYSTEME" Style="{StaticResource DashTitle}"/>
                                    <StackPanel Orientation="Horizontal">
                                        <TextBlock Name="lblChassis" Text="Chargement..." Style="{StaticResource DashValue}" Margin="0,0,15,0"/>
                                        <TextBlock Text="|" Foreground="#333" FontSize="18" Margin="0,0,15,0"/>
                                        <TextBlock Name="lblOS" Text="..." Style="{StaticResource DashValue}" FontSize="16" Foreground="#AAA" VerticalAlignment="Center"/>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="STOCKAGE &amp; SANTE" Style="{StaticResource DashTitle}"/>
                                    <TextBlock Name="lblStorage" Text="Chargement..." Style="{StaticResource DashValue}" FontSize="14"/>
                                </StackPanel>
                            </Border>

                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="PROCESSEUR (CPU)" Style="{StaticResource DashTitle}"/>
                                    <TextBlock Name="lblCPU" Text="Chargement..." Style="{StaticResource DashValue}"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,5,0,0">
                                        <TextBlock Text="Version Pilote : " Foreground="Gray"/>
                                        <TextBlock Name="lblCPUDriver" Text="..." FontWeight="Bold"/>
                                    </StackPanel>
                                    <Button Name="linkCPU" Content="[ TELECHARGER PILOTES (OFFICIEL) ]" Style="{StaticResource LinkBtn}"/>
                                </StackPanel>
                            </Border>

                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="CARTE GRAPHIQUE (GPU)" Style="{StaticResource DashTitle}"/>
                                    <TextBlock Name="lblGPU" Text="Chargement..." Style="{StaticResource DashValue}"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,5,0,0">
                                        <TextBlock Text="Version Pilote : " Foreground="Gray"/>
                                        <TextBlock Name="lblGPUDriver" Text="..." FontWeight="Bold"/>
                                    </StackPanel>
                                    <Button Name="linkGPU" Content="[ TELECHARGER PILOTES (OFFICIEL) ]" Style="{StaticResource LinkBtn}"/>
                                </StackPanel>
                            </Border>

                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="MEMOIRE VIVE (RAM)" Style="{StaticResource DashTitle}"/>
                                    <TextBlock Name="lblRAM" Text="Chargement..." Style="{StaticResource DashValue}"/>
                                    <TextBlock Name="lblXMP" Text="..." FontSize="14" Margin="0,5,0,0"/>
                                </StackPanel>
                            </Border>

                            <Border Style="{StaticResource DashCard}">
                                <StackPanel>
                                    <TextBlock Text="CARTE MERE &amp; BIOS" Style="{StaticResource DashTitle}"/>
                                    <TextBlock Name="lblMobo" Text="Chargement..." Style="{StaticResource DashValue}"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,5,0,0">
                                        <TextBlock Text="Version BIOS : " Foreground="Gray"/>
                                        <TextBlock Name="lblBIOS" Text="..." Foreground="White"/>
                                    </StackPanel>
                                    <Button Name="linkMobo" Content="[ RECHERCHER MAJ BIOS ]" Style="{StaticResource LinkBtn}"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </TabItem>

            <TabItem Header="INSTALLATION">
                <Grid Margin="10">
                    <Grid.RowDefinitions><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <WrapPanel Orientation="Horizontal" ItemWidth="280">
                            
                            <StackPanel Margin="15">
                                <TextBlock Text="BROWSERS" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_Chrome" Content="Google Chrome" Tag="Google.Chrome"/>
                                <CheckBox Name="app_Firefox" Content="Firefox" Tag="Mozilla.Firefox"/>
                                <CheckBox Name="app_Brave" Content="Brave" Tag="Brave.Brave"/>
                                <CheckBox Name="app_Edge" Content="Microsoft Edge" Tag="Microsoft.Edge"/>
                                <CheckBox Name="app_Tor" Content="Tor Browser" Tag="TorProject.TorBrowser"/>
                                <CheckBox Name="app_Vivaldi" Content="Vivaldi" Tag="Vivaldi.Vivaldi"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="COMMUNICATION" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_Discord" Content="Discord" Tag="Discord.Discord"/>
                                <CheckBox Name="app_Teams" Content="Microsoft Teams" Tag="Microsoft.Teams"/>
                                <CheckBox Name="app_Zoom" Content="Zoom" Tag="Zoom.Zoom"/>
                                <CheckBox Name="app_Tele" Content="Telegram" Tag="Telegram.TelegramDesktop"/>
                                <CheckBox Name="app_Signal" Content="Signal" Tag="Signal.Signal"/>
                                <CheckBox Name="app_WhatsApp" Content="WhatsApp" Tag="WhatsApp.WhatsApp"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="DEVELOPMENT" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_Code" Content="VS Code" Tag="Microsoft.VisualStudioCode"/>
                                <CheckBox Name="app_Git" Content="Git" Tag="Git.Git"/>
                                <CheckBox Name="app_Python" Content="Python 3" Tag="Python.Python.3"/>
                                <CheckBox Name="app_Node" Content="Node.js" Tag="OpenJS.NodeJS"/>
                                <CheckBox Name="app_Notepad" Content="Notepad++" Tag="Notepad++.Notepad++"/>
                                <CheckBox Name="app_Sublime" Content="Sublime Text" Tag="SublimeHQ.SublimeText.4"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="DOCUMENTS" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_AdobeReader" Content="Adobe Reader" Tag="Adobe.Acrobat.Reader.64-bit"/>
                                <CheckBox Name="app_LibreOffice" Content="LibreOffice" Tag="TheDocumentFoundation.LibreOffice"/>
                                <CheckBox Name="app_Obsidian" Content="Obsidian" Tag="Obsidian.Obsidian"/>
                                <CheckBox Name="app_Notion" Content="Notion" Tag="Notion.Notion"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="MULTIMEDIA" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_VLC" Content="VLC Player" Tag="VideoLAN.VLC"/>
                                <CheckBox Name="app_OBS" Content="OBS Studio" Tag="OBSProject.OBSStudio"/>
                                <CheckBox Name="app_Hand" Content="HandBrake" Tag="HandBrake.HandBrake"/>
                                <CheckBox Name="app_Spot" Content="Spotify" Tag="Spotify.Spotify"/>
                                <CheckBox Name="app_Aud" Content="Audacity" Tag="Audacity.Audacity"/>
                                <CheckBox Name="app_GIMP" Content="GIMP" Tag="GIMP.GIMP"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="TOOLS &amp; UTILITIES" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_7zip" Content="7-Zip" Tag="7zip.7zip"/>
                                <CheckBox Name="app_WinRAR" Content="WinRAR" Tag="RARLab.WinRAR"/>
                                <CheckBox Name="app_Power" Content="PowerToys" Tag="Microsoft.PowerToys"/>
                                <CheckBox Name="app_Rufus" Content="Rufus" Tag="Rufus.Rufus"/>
                                <CheckBox Name="app_AnyDesk" Content="AnyDesk" Tag="AnyDeskSoftwareGmbH.AnyDesk"/>
                                <CheckBox Name="app_CPUZ" Content="CPU-Z" Tag="CPUID.CPU-Z"/>
                                <CheckBox Name="app_Bleach" Content="BleachBit" Tag="BleachBit.BleachBit"/>
                                <CheckBox Name="app_Everything" Content="Everything" Tag="voidtools.Everything"/>
                            </StackPanel>

                            <StackPanel Margin="15">
                                <TextBlock Text="GAMES" Style="{StaticResource Header}"/>
                                <CheckBox Name="app_Steam" Content="Steam" Tag="Valve.Steam"/>
                                <CheckBox Name="app_Epic" Content="Epic Games" Tag="EpicGames.EpicGamesLauncher"/>
                                <CheckBox Name="app_Ubisoft" Content="Ubisoft Connect" Tag="Ubisoft.Connect"/>
                                <CheckBox Name="app_EA" Content="EA App" Tag="ElectronicArts.EADesktop"/>
                            </StackPanel>

                        </WrapPanel>
                    </ScrollViewer>
                    <Button Grid.Row="1" Name="btnInstall" Content="INSTALLER LA SELECTION" Height="45" Width="300" Background="#007ACC" FontWeight="Bold" HorizontalAlignment="Right" Margin="20"/>
                </Grid>
            </TabItem>

            <TabItem Header="TWEAKS">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
                        <TextBlock Text="PRESETS RAPIDES : " VerticalAlignment="Center" Foreground="#AAA" Margin="0,0,10,0"/>
                        <Button Name="pre_Safe" Content="SAFE (Recommande)" Width="150" Background="#2ECC71"/>
                        <Button Name="pre_Laptop" Content="PC PORTABLE (Eco)" Width="150" Background="#F1C40F" Foreground="Black"/>
                        <Button Name="pre_Gaming" Content="GAMING (Perf)" Width="150" Background="#E74C3C"/>
                    </StackPanel>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="30"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="30"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <Border Grid.Column="0" Background="#1E1E1E" CornerRadius="8" Padding="15">
                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                <StackPanel>
                                    <TextBlock Text="ESSENTIEL (SAFE)" Style="{StaticResource Header}" Foreground="#00FF00"/>
                                    
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Restore" Content="Creer Point de Restauration" IsChecked="True"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Cree une sauvegarde du systeme. POURQUOI: Securite indispensable avant modif."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Temp" Content="Supprimer Fichiers Temp"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Vide les dossiers Temp, Prefetch et Logs. POURQUOI: Libere de l'espace disque."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Telem" Content="Desactiver Telemetrie"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Bloque l'envoi de donnees a Microsoft. POURQUOI: Confidentialite et economie bande passante."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Wifi" Content="Desactiver Wi-Fi Sense"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Bloque le partage automatique de MDP Wifi. POURQUOI: Securite reseau."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Act" Content="Desactiver Historique Activite"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Arrete le suivi des fichiers ouverts (Timeline). POURQUOI: Vie privee."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Loc" Content="Desactiver Localisation"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Coupe le GPS global Windows. POURQUOI: Empeche le tracage."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Cons" Content="Desactiver Consumer Features"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Stop l'installation auto d'apps pub (CandyCrush). POURQUOI: Garde le systeme propre."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_DVR" Content="Desactiver GameDVR"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Coupe l'enregistrement Xbox en fond. POURQUOI: Gain FPS et moins de lag."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Hib" Content="Desactiver Hibernation"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Supprime hiberfil.sys. POURQUOI: Gain 5-10 Go sur SSD."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_End" Content="Fin de Tache (Clic Droit)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Option pour tuer une app via la barre des taches. POURQUOI: Gestion rapide des crashs."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_IP4" Content="Preferer IPv4 sur IPv6"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Force le protocole IPv4. POURQUOI: Meilleure stabilite reseau/jeux."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Svc" Content="Services en Manuel"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Services de diagnostic en manuel. POURQUOI: Moins de processus en fond."/></StackPanel>
                                </StackPanel>
                            </ScrollViewer>
                        </Border>

                        <Border Grid.Column="2" Background="#1E1E1E" CornerRadius="8" Padding="15">
                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                <StackPanel>
                                    <TextBlock Text="AVANCE" Style="{StaticResource Header}" Foreground="#FF4444"/>
                                    
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Adobe" Content="Adobe Debloat"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Coupe les services Adobe en fond. POURQUOI: Performance."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Bck" Content="Stop Apps Arriere-plan"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Bloque les apps Store en fond. POURQUOI: Economie RAM/Batterie."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_FSO" Content="Desactiver Opti Plein Ecran"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Desactive FSO. POURQUOI: Reduit l'input lag en jeu."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Intel" Content="Desactiver Intel MM"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Service vPro. POURQUOI: Inutile pour particuliers."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Cop" Content="Desactiver Copilot"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Supprime l'IA Microsoft. POURQUOI: Gain place/ressources."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Not" Content="Desactiver Notifs/Calendrier"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Cache la zone de notification et l'horloge. POURQUOI: Pour un bureau ultra-minimaliste (Attention : plus d'heure visible)."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Ter" Content="Desactiver Teredo"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Tunnel IPv6. POURQUOI: Securite (Sauf Xbox Live)."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_DNS" Content="DNS Rapides (Google)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Met DNS 8.8.8.8. POURQUOI: Internet plus rapide."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Str" Content="Supprimer MS Store"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Desinstalle la boutique. POURQUOI: Radical. ATTENTION (Risque)."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_HGl" Content="Retirer Accueil/Galerie"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Nettoie l'explorateur. POURQUOI: Visuel."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Edg" Content="Supprimer Edge"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Force desinstallation Edge. POURQUOI: Anti-Microsoft. (Risque)."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_One" Content="Supprimer OneDrive"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Desinstalle OneDrive. POURQUOI: Stop synchro."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_OO" Content="Lancer O&amp;O ShutUp10"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Outil externe expert. POURQUOI: Confidentialite avancee."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_Mnu" Content="Menu Clic-Droit Classique"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Remet le menu W10. POURQUOI: Plus d'options."/></StackPanel>
                                    <StackPanel Orientation="Horizontal"><CheckBox Name="tw_UTC" Content="Heure UTC (Dual Boot)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Fixe l'heure BIOS. POURQUOI: Pour Linux."/></StackPanel>
                                </StackPanel>
                            </ScrollViewer>
                        </Border>

                        <Border Grid.Column="4" Background="#1E1E1E" CornerRadius="8" Padding="15">
                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                <StackPanel>
                                    <TextBlock Text="PREFERENCES (INSTANTANE)" Style="{StaticResource Header}" Foreground="#FFD700"/>
                                    
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Bing" Style="{StaticResource Toggle}"/><TextBlock Text="Recherche Bing" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Affiche les resultats web dans le menu. OFF: Recherche locale uniquement."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Center" Style="{StaticResource Toggle}"/><TextBlock Text="Barre Taches Centree" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Icones au centre (W11). OFF: Icones a gauche (Style W10)."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Dark" Style="{StaticResource Toggle}"/><TextBlock Text="Theme Sombre" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Mode sombre. OFF: Mode clair."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_BSOD" Style="{StaticResource Toggle}"/><TextBlock Text="BSOD Detaille" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Affiche les codes d'erreur lors d'un crash."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Accel" Style="{StaticResource Toggle}"/><TextBlock Text="Accel Souris" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Precision pointeur activee. OFF: Mouvement brut (Raw Input) conseille pour les FPS."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Num" Style="{StaticResource Toggle}"/><TextBlock Text="VerrNum Boot" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Active le pave numerique au demarrage."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Ext" Style="{StaticResource Toggle}"/><TextBlock Text="Voir Extensions" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Affiche .exe, .txt. OFF: Cache les extensions."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Hidden" Style="{StaticResource Toggle}"/><TextBlock Text="Voir Fichiers Caches" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Affiche les fichiers masques par le systeme."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Snap" Style="{StaticResource Toggle}"/><TextBlock Text="Snap Assist" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Aide a l'ancrage des fenetres. OFF: Desactive."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Sticky" Style="{StaticResource Toggle}"/><TextBlock Text="Sticky Keys" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Active les touches remanentes (Shift 5x). OFF: Desactive."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Wid" Style="{StaticResource Toggle}"/><TextBlock Text="Widgets" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Affiche Meteo/News. OFF: Gain de place et RAM."/></StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,2"><CheckBox Name="pf_Clip" Style="{StaticResource Toggle}"/><TextBlock Text="Presse-papiers (Win+V)" Foreground="White" VerticalAlignment="Center" Margin="10,0"/><TextBlock Style="{StaticResource Tip}" ToolTip="ON: Active l'historique Win+V."/></StackPanel>
                                </StackPanel>
                            </ScrollViewer>
                        </Border>
                    </Grid>
                </Grid>
            </TabItem>

            <TabItem Header="CONFIG">
                <Grid Margin="10">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    
                    <Border Grid.Column="0" Background="#1E1E1E" CornerRadius="8" Padding="15" Margin="0,0,10,0">
                        <ScrollViewer>
                            <StackPanel>
                                <TextBlock Text="FONCTIONNALITES WINDOWS" Style="{StaticResource Header}"/>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_Net" Content="Installer .NET Framework (2,3,4)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Installe les versions 2.0, 3.0 et 3.5. POURQUOI: Necessaire pour anciens jeux."/></StackPanel>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_Hyp" Content="Activer Hyper-V"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Technologie virtualisation. POURQUOI: Pour machines virtuelles (VM)."/></StackPanel>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_Sand" Content="Activer Sandbox"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Bac a sable Windows. POURQUOI: Tester fichiers suspects."/></StackPanel>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_WSL" Content="Activer WSL (Linux)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Sous-systeme Linux. POURQUOI: Terminal Ubuntu dans Windows."/></StackPanel>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_Med" Content="Activer Legacy Media (DirectPlay)"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: DirectPlay et WMP. POURQUOI: Vieux jeux (GTA SA)."/></StackPanel>
                                <StackPanel Orientation="Horizontal"><CheckBox Name="ft_NFS" Content="Activer NFS Client"/><TextBlock Style="{StaticResource Tip}" ToolTip="QUOI: Network File System. POURQUOI: Connexion NAS/Linux."/></StackPanel>
                                
                                <Button Name="btnFeat" Content="APPLIQUER LA CONFIG" Width="250" HorizontalAlignment="Left" Background="#00A4EF" Margin="0,20,0,0"/>
                                
                                <TextBlock Text="OUTILS SYSTEME" Style="{StaticResource Header}" Margin="0,20,0,10"/>
                                <Button Name="btnPanel" Content="Panneau Configuration" Background="#333"/>
                                <Button Name="btnNet" Content="Connexions Reseau (NCPA)" Background="#333"/>
                                <Button Name="btnSound" Content="Parametres Son (MMSYS)" Background="#333"/>
                                <Button Name="btnWUP" Content="Reparer Windows Update" Background="#333"/>
                                <Button Name="btnResetNet" Content="Reset Reseau (Winsock)" Background="#333"/>
                                <Button Name="btnSFC" Content="Scan Corruption (SFC)" Background="#333"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>

                    <Border Grid.Column="1" Background="#1E1E1E" CornerRadius="8" Padding="15" Margin="10,0,0,0">
                        <ScrollViewer>
                            <StackPanel>
                                <TextBlock Text="DEBLOAT (SCAN AUTOMATIQUE)" Style="{StaticResource Header}" Foreground="#E74C3C"/>
                                <TextBlock Text="Le script detecte les applications installees :" Foreground="#AAA" Margin="0,0,0,10"/>
                                
                                <CheckBox Name="bl_Xbox" Content="Xbox App"/>
                                <CheckBox Name="bl_Sol" Content="Solitaire Collection"/>
                                <CheckBox Name="bl_Bing" Content="Meteo / News (Bing)"/>
                                <CheckBox Name="bl_Phone" Content="Lien Mobile (YourPhone)"/>
                                <CheckBox Name="bl_Feed" Content="Feedback Hub"/>
                                <CheckBox Name="bl_Map" Content="Cartes (Maps)"/>
                                <CheckBox Name="bl_Cort" Content="Cortana"/>
                                <CheckBox Name="bl_Cam" Content="Camera"/>
                                <CheckBox Name="bl_Calc" Content="Calculatrice (Attention)"/>
                                
                                <Button Name="btnKillBloat" Content="SUPPRIMER LA SELECTION" Background="#800000" Margin="0,15,0,0" FontWeight="Bold"/>

                                <TextBlock Text="DEMARRAGE" Style="{StaticResource Header}" Foreground="#E74C3C" Margin="0,30,0,5"/>
                                <Button Name="btnOpenStart" Content="Gerer le Demarrage (Parametres)" Background="#2D2D30"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </TabItem>
        </TabControl>

        <Border Grid.Row="2" Background="#111" BorderBrush="#333" BorderThickness="0,1,0,0">
            <Grid>
                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <ScrollViewer Name="scrollLog" VerticalScrollBarVisibility="Auto" Margin="20">
                    <TextBlock Name="txtLog" Text="[SYSTEME] Pret." Foreground="#00FF00" FontFamily="Consolas" FontSize="12"/>
                </ScrollViewer>
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="20">
                    <Button Name="btnRun" Content="LANCER LES TWEAKS" Width="250" Height="50" Background="#00A4EF" FontWeight="Bold" FontSize="14">
                        <Button.Effect>
                            <DropShadowEffect Color="#00A4EF" BlurRadius="10" ShadowDepth="0" Opacity="0.4"/>
                        </Button.Effect>
                    </Button>
                </StackPanel>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# 4. MOTEUR LOGIQUE
try {
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "ERREUR INTERFACE: $_"
    Read-Host "Entree..."
    Exit
}

function Log($m) {
    $window.Dispatcher.Invoke({
        $tb = $window.FindName("txtLog")
        $sv = $window.FindName("scrollLog")
        $tb.Text += "`n> $m"
        $sv.ScrollToEnd()
    })
}

function Get-Reg($path, $name) { $v = Get-ItemProperty $path $name -ErrorAction SilentlyContinue; if ($v) { return $v.$name } return $null }

# --- INSTANT PREFS ---
function Apply-InstantPref($id, $state) {
    Log "Pref changee."
    switch ($id) {
        "pf_Dark" {
            $v = if ($state) { 0 } else { 1 }
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" $v -Force
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" $v -Force
        }
        "pf_Bing" {
            $v = if ($state) { 0 } else { 1 }
            New-Item "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
            Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" $v -Force
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        }
        "pf_Center" {
            $v = if ($state) { 1 } else { 0 }
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" $v -Force
        }
        "pf_Accel" {
            $v = if ($state) { "1" } else { "0" }
            Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" $v -Force
        }
        "pf_Num" {
            $v = if ($state) { "2" } else { "0" }
            Set-ItemProperty "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" $v -Force
        }
        "pf_Ext" {
            $v = if ($state) { 0 } else { 1 }
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" $v -Force
        }
        "pf_Hidden" {
            $v = if ($state) { 1 } else { 2 }
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" $v -Force
        }
        "pf_Wid" {
            $v = if ($state) { 1 } else { 0 }
            New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" $v -Force -ErrorAction SilentlyContinue
        }
        "pf_Sticky" {
            $v = if ($state) { "510" } else { "506" }
            Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" $v -Force
        }
        "pf_Clip" {
            $v = if ($state) { 1 } else { 0 }
            Set-ItemProperty "HKCU:\Software\Microsoft\Clipboard" "EnableClipboardHistory" $v -Force
        }
    }
    # REFRESH EXPLORER POUR APPLIQUER (UNIQUEMENT SI NECESSAIRE)
    if ($id -match "pf_Dark|pf_Center|pf_Ext|pf_Hidden") {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    }
}

# --- SMART DETECTION LOGIC ---
function Clean-String($s) {
    if (-not $s) { return "Inconnu" }
    # Nettoyage des marques pour un affichage plus propre
    $s = $s -replace "\(R\)|\(TM\)|CPU|@.*", "" -replace "\s+", " "
    $s = $s -replace "Micro-Star International Co., Ltd.", "MSI"
    $s = $s -replace "ASUSTeK COMPUTER INC.", "ASUS"
    $s = $s -replace "Gigabyte Technology Co., Ltd.", "GIGABYTE"
    return $s.Trim()
}

function Open-DriverPage($type) {
    if ($type -eq "GPU") {
        $name = $window.FindName("lblGPU").Text # LIT LE TEXTE A L'ECRAN (INFAILLIBLE)
        Start-Process "https://www.google.com/search?q=Driver+$name+official+download"
    }
    elseif ($type -eq "CPU") {
        $name = $window.FindName("lblCPU").Text # LIT LE TEXTE A L'ECRAN
        Start-Process "https://www.google.com/search?q=Driver+$name+official+download"
    }
    elseif ($type -eq "MOBO") {
        $name = $window.FindName("lblMobo").Text # LIT LE TEXTE A L'ECRAN
        Start-Process "https://www.google.com/search?q=$name+bios+update+official+site"
    }
}

function Update-Dashboard {
    Log "Scan Materiel..."
    
    # 1. CHASSIS
    $chassis = Get-CimInstance Win32_SystemEnclosure
    $typeStr = if ($chassis.ChassisTypes[0] -in 9,10,14) { "LAPTOP (PORTABLE)" } else { "DESKTOP (TOUR)" }
    $window.FindName("lblChassis").Text = $typeStr
    if ($typeStr -match "LAPTOP") { $window.FindName("lblChassis").Foreground = "#F1C40F" } else { $window.FindName("lblChassis").Foreground = "#2ECC71" }

    # 2. OS
    $os = Get-CimInstance Win32_OperatingSystem
    $window.FindName("lblOS").Text = $os.Caption

    # 3. STOCKAGE
    $disks = Get-PhysicalDisk | Where-Object MediaType -ne "Unspecified"
    $diskTxt = ""
    foreach ($d in $disks) {
        $color = if ($d.HealthStatus -eq "Healthy") { "[SAIN]" } else { "[ATTENTION]" }
        $diskTxt += "$($d.FriendlyName) - $color`n"
    }
    $window.FindName("lblStorage").Text = $diskTxt
    if ($diskTxt -match "ATTENTION") { $window.FindName("lblStorage").Foreground = "#E74C3C" } else { $window.FindName("lblStorage").Foreground = "#2ECC71" }

    # 4. CPU (SMART)
    $cpu = Get-CimInstance Win32_Processor
    $cleanCPU = Clean-String $cpu.Name
    $window.FindName("lblCPU").Text = $cleanCPU
    
    # Version Pilote CPU (Recherche approfondie classe PROCESSOR)
    $cpuVer = "Gere par Windows"
    try { 
        # On cherche le pilote genere par Windows pour le CPU
        $drv = Get-CimInstance Win32_PnPSignedDriver | Where-Object {$_.DeviceClass -eq "PROCESSOR"} | Select-Object -First 1
        if($drv) { $cpuVer = $drv.DriverVersion }
    } catch {}
    
    $window.FindName("lblCPUDriver").Text = $cpuVer
    $window.FindName("lblCPUDriver").Foreground = "#2ECC71"

    # IMPORTANT : On capture le nom du CPU dans une variable locale pour le clic
    $finalCpuName = $cleanCPU
    # On stocke le nom propre dans le Tag du bouton pour eviter le bug de variable
    $btnCPU = $window.FindName("linkCPU")
    $btnCPU.Tag = $finalCpuName
    # On retire les anciens event handlers pour eviter les doublons lors du refresh
    $btnCPU.Remove_Click($btnCPU_Click)
    $btnCPU_Click = { Open-DriverPage "CPU" }
    $btnCPU.Add_Click($btnCPU_Click)

    # 5. GPU (SMART)
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $cleanGPU = Clean-String $gpu.Name
    $window.FindName("lblGPU").Text = $cleanGPU
    
    # Version Pilote GPU
    $gpuVer = "Inconnue"
    if ($gpu.DriverVersion) { $gpuVer = $gpu.DriverVersion }
    $window.FindName("lblGPUDriver").Text = $gpuVer
    $window.FindName("lblGPUDriver").Foreground = "#2ECC71"

    $finalGpuName = $cleanGPU
    $btnGPU = $window.FindName("linkGPU")
    $btnGPU.Tag = $finalGpuName
    $btnGPU.Remove_Click($btnGPU_Click)
    $btnGPU_Click = { Open-DriverPage "GPU" }
    $btnGPU.Add_Click($btnGPU_Click)

    # 6. RAM
    $mem = Get-CimInstance Win32_PhysicalMemory
    $totalGB = [math]::Round(($mem | Measure-Object -Property Capacity -Sum).Sum / 1GB)
    $speed = $mem[0].Speed
    $window.FindName("lblRAM").Text = "$totalGB Go - $speed MHz"
    
    $xmpTxt = if ($speed -gt 3200) { "XMP : ACTIF" } else { "XMP : STANDARD" }
    $window.FindName("lblXMP").Text = $xmpTxt
    if ($xmpTxt -match "ACTIF") { $window.FindName("lblXMP").Foreground = "#2ECC71" }

    # 7. BIOS
    $board = Get-CimInstance Win32_BaseBoard
    $cleanMobo = Clean-String $board.Manufacturer
    $model = $board.Product
    $fullMobo = "$cleanMobo - $model"
    
    $window.FindName("lblMobo").Text = $fullMobo
    $bios = Get-CimInstance Win32_BIOS
    $window.FindName("lblBIOS").Text = "$($bios.SMBIOSBIOSVersion)"
    
    $btnMobo = $window.FindName("linkMobo")
    $btnMobo.Tag = $fullMobo
    $btnMobo.Remove_Click($btnMobo_Click)
    $btnMobo_Click = { Open-DriverPage "MOBO" }
    $btnMobo.Add_Click($btnMobo_Click)
    
    Log "Scan termine."
}

# --- PRESETS LOGIC ---
$window.FindName("pre_Safe").Add_Click({
    $window.FindName("tw_Restore").IsChecked = $true
    $window.FindName("tw_Temp").IsChecked = $true
    $window.FindName("tw_Telem").IsChecked = $true
    $window.FindName("tw_Cons").IsChecked = $true
    Log "Preset SAFE applique."
})
$window.FindName("pre_Laptop").Add_Click({
    $window.FindName("tw_Bck").IsChecked = $true
    $window.FindName("tw_Act").IsChecked = $true
    $window.FindName("tw_Loc").IsChecked = $true
    $window.FindName("tw_Hib").IsChecked = $false
    Log "Preset LAPTOP applique."
})
$window.FindName("pre_Gaming").Add_Click({
    $window.FindName("tw_DVR").IsChecked = $true
    $window.FindName("tw_FSO").IsChecked = $true
    $window.FindName("tw_Hib").IsChecked = $true
    $window.FindName("tw_IP4").IsChecked = $true
    $window.FindName("tw_Telem").IsChecked = $true
    Log "Preset GAMING applique."
})

# --- DEBLOAT INTELLIGENT ---
function Check-App($name, $chkName) {
    $chk = $window.FindName($chkName)
    $pkg = Get-AppxPackage -Name $name -ErrorAction SilentlyContinue
    if ($pkg) {
        $chk.IsEnabled = $true
        $chk.Content = "$($chk.Content) (Installe)"
        $chk.Foreground = "#FFFFFF" 
    } else {
        $chk.IsEnabled = $false
        $chk.IsChecked = $false
        $chk.Content = "$($chk.Content) (Absent)"
        $chk.Foreground = "#555555" 
    }
}

$window.FindName("btnKillBloat").Add_Click({
    Log "Suppression des Apps..."
    $map = @{"bl_Xbox"="*Xbox*"; "bl_Sol"="*Solitaire*"; "bl_Bing"="*Bing*"; "bl_Phone"="*YourPhone*"; "bl_Feed"="*FeedbackHub*"; "bl_Map"="*Maps*"; "bl_Cort"="*Cortana*"; "bl_Cam"="*WindowsCamera*"; "bl_Calc"="*Calculator*"}
    
    foreach ($k in $map.Keys) {
        if ($window.FindName($k).IsChecked) {
            Get-AppxPackage $map[$k] | Remove-AppxPackage -ErrorAction SilentlyContinue
            Log "Supprime: $k"
        }
    }
    Log "Termine."
    [System.Windows.Forms.MessageBox]::Show("Applications supprimees !", "Debloat")
    Scan-All-States
})

# --- STARTUP LINK ---
$window.FindName("btnOpenStart").Add_Click({
    Start-Process "ms-settings:startupapps"
})

# --- SCAN GLOBAL ---
function Scan-All-States {
    Log "Detection ETAT SYSTEME..."
    Update-Dashboard

    # 1. Check Tweaks
    if ((Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry") -eq 0) { $window.FindName("tw_Telem").IsChecked = $true }
    if ((Get-Reg "HKCU:\System\GameConfigStore" "GameDVR_Enabled") -eq 0) { $window.FindName("tw_DVR").IsChecked = $true }
    if ((Get-Reg "HKCU:\Control Panel\Desktop" "AutoEndTasks") -eq 1) { $window.FindName("tw_End").IsChecked = $true }
    if ((Get-Reg "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" "value") -eq 0) { $window.FindName("tw_Wifi").IsChecked = $true }
    
    # 2. Check Prefs
    if ((Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme") -eq 0) { $window.FindName("pf_Dark").IsChecked = $true }
    if ((Get-Reg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions") -ne 1) { $window.FindName("pf_Bing").IsChecked = $true }
    if ((Get-Reg "HKCU:\Control Panel\Mouse" "MouseSpeed") -ne "0") { $window.FindName("pf_Accel").IsChecked = $true }
    if ((Get-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt") -eq 0) { $window.FindName("pf_Ext").IsChecked = $true }
    if ((Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests") -ne 0) { $window.FindName("pf_Wid").IsChecked = $true }
    if ((Get-Reg "HKCU:\Software\Microsoft\Clipboard" "EnableClipboardHistory") -eq 1) { $window.FindName("pf_Clip").IsChecked = $true }

    # 3. Check Apps
    Check-App "*Xbox*" "bl_Xbox"
    Check-App "*Solitaire*" "bl_Sol"
    Check-App "*Bing*" "bl_Bing"
    Check-App "*YourPhone*" "bl_Phone"
    Check-App "*FeedbackHub*" "bl_Feed"
    Check-App "*Maps*" "bl_Map"
    Check-App "*Cortana*" "bl_Cort"
    Check-App "*WindowsCamera*" "bl_Cam"
    Check-App "*Calculator*" "bl_Calc"
}

$window.Add_Loaded({
    Scan-All-States
    
    $prefs = @("pf_Dark","pf_Bing","pf_Center","pf_Accel","pf_Num","pf_Ext","pf_Hidden","pf_Wid","pf_Sticky","pf_Clip")
    foreach ($p in $prefs) {
        $chk = $window.FindName($p)
        if ($chk) { $chk.Add_Click({ Apply-InstantPref $this.Name $this.IsChecked }) }
    }
})

$window.FindName("btnScanPC").Add_Click({ Scan-All-States })

# --- INSTALL & TWEAKS ---
$window.FindName("btnInstall").Add_Click({
    Start-Process winget "source update" -Wait -WindowStyle Hidden
    
    $apps = @{
        "app_Chrome"="Google.Chrome"; "app_Firefox"="Mozilla.Firefox"; "app_Brave"="Brave.Brave"; "app_Edge"="Microsoft.Edge"; "app_Tor"="TorProject.TorBrowser"; "app_Vivaldi"="Vivaldi.Vivaldi";
        "app_Discord"="Discord.Discord"; "app_Teams"="Microsoft.Teams"; "app_Zoom"="Zoom.Zoom"; "app_Tele"="Telegram.TelegramDesktop"; "app_Signal"="Signal.Signal"; "app_WhatsApp"="WhatsApp.WhatsApp";
        "app_CPUZ"="CPUID.CPU-Z"; "app_Bleach"="BleachBit.BleachBit"; "app_Rufus"="Rufus.Rufus"; "app_Power"="Microsoft.PowerToys"; "app_7zip"="7zip.7zip"; "app_WinRAR"="RARLab.WinRAR"; "app_AnyDesk"="AnyDeskSoftwareGmbH.AnyDesk"; "app_Everything"="voidtools.Everything";
        "app_VLC"="VideoLAN.VLC"; "app_OBS"="OBSProject.OBSStudio"; "app_Hand"="HandBrake.HandBrake"; "app_Spot"="Spotify.Spotify"; "app_Aud"="Audacity.Audacity"; "app_GIMP"="GIMP.GIMP";
        "app_Code"="Microsoft.VisualStudioCode"; "app_Note"="Notepad++.Notepad++"; "app_Steam"="Valve.Steam"; "app_Epic"="EpicGames.EpicGamesLauncher"; "app_Git"="Git.Git"; "app_Node"="OpenJS.NodeJS"; "app_Python"="Python.Python.3"; "app_Sublime"="SublimeHQ.SublimeText.4"; "app_AdobeReader"="Adobe.Acrobat.Reader.64-bit"; "app_LibreOffice"="TheDocumentFoundation.LibreOffice"; "app_Obsidian"="Obsidian.Obsidian"; "app_Notion"="Notion.Notion"; "app_Ubisoft"="Ubisoft.Connect"; "app_EA"="ElectronicArts.EADesktop"
    }

    foreach ($key in $apps.Keys) {
        $chk = $window.FindName($key)
        if ($chk.IsChecked) {
            Log "Installation: $($chk.Content)"
            if ($key -eq "app_AnyDesk") {
                $p = Start-Process winget "install AnyDeskSoftwareGmbH.AnyDesk -e --silent --accept-source-agreements --accept-package-agreements" -PassThru -Wait -WindowStyle Hidden
                if ($p.ExitCode -ne 0) {
                    Invoke-WebRequest "https://download.anydesk.com/AnyDesk.exe" -OutFile "$env:TEMP\AnyDesk.exe"
                    Start-Process "$env:TEMP\AnyDesk.exe" "--install `"$env:ProgramFiles(x86)\AnyDesk`" --start-with-win --silent"
                }
            } else {
                Start-Process winget "install -e --id $($apps[$key]) --accept-source-agreements --accept-package-agreements" -Wait -WindowStyle Hidden
            }
        }
    }
    Log "Installations finies."
})

$window.FindName("btnRun").Add_Click({
    Log "Application Tweaks..."
    if ($window.FindName("tw_Restore").IsChecked) { 
        Log "Creation Point de Restauration (Patientez)..."
        # Force enable restore
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "MaTows" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    }
    if ($window.FindName("tw_Temp").IsChecked) { Remove-Item "$env:TEMP\*" -Recurse -Force }
    
    $v = if ($window.FindName("tw_Telem").IsChecked) { 0 } else { 1 }
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" $v -Force

    $v = if ($window.FindName("tw_Wifi").IsChecked) { 0 } else { 1 }
    New-ItemProperty "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" "value" $v -Force -ErrorAction SilentlyContinue | Out-Null

    $v = if ($window.FindName("tw_Act").IsChecked) { 0 } else { 1 }
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" $v -Force

    $v = if ($window.FindName("tw_Loc").IsChecked) { 1 } else { 0 }
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" $v -Force

    $v = if ($window.FindName("tw_DVR").IsChecked) { 0 } else { 1 }
    Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" $v -Force

    if ($window.FindName("tw_Hib").IsChecked) { powercfg /h off } else { powercfg /h on }
    
    $v = if ($window.FindName("tw_End").IsChecked) { 1 } else { 0 }
    Set-ItemProperty "HKCU:\Control Panel\Desktop" "AutoEndTasks" $v -Force

    if ($window.FindName("tw_IP4").IsChecked) { New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0x20 -PropertyType DWord -Force | Out-Null }
    if ($window.FindName("tw_Svc").IsChecked) { Set-Service "DiagTrack" -StartupType Manual; Set-Service "WwerSvc" -StartupType Manual }

    if ($window.FindName("tw_Adobe").IsChecked) { Stop-Service "AdobeARMservice" -ErrorAction SilentlyContinue; Set-Service "AdobeARMservice" -StartupType Disabled }
    if ($window.FindName("tw_Bck").IsChecked) { New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1 -Force }
    if ($window.FindName("tw_FSO").IsChecked) { New-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_FSEBehavior" 2 -Force }
    if ($window.FindName("tw_Cop").IsChecked) { New-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1 -Force }
    if ($window.FindName("tw_One").IsChecked) { Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue; $o="$env:SystemRoot\SysWOW64\OneDriveSetup.exe"; if(Test-Path $o){Start-Process $o "/uninstall" -Wait} }
    if ($window.FindName("tw_Mnu").IsChecked) { New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null; Set-ItemProperty "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "(default)" "" -Force }
    if ($window.FindName("tw_OO").IsChecked) { $u="https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"; $d="$env:TEMP\OOSU10.exe"; Invoke-WebRequest $u -OutFile $d; Start-Process $d }

    Log "Termine. Redemarrage conseille."
    # Force Restart Message
    $res = [System.Windows.Forms.MessageBox]::Show("Optimisation terminée.`nLe PC va redémarrer pour appliquer les changements.", "MaTows Utility", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($res -eq "OK") { Restart-Computer -Force }
})

$window.FindName("btnFeat").Add_Click({
    if ($window.FindName("ft_Net").IsChecked) { Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart }
    if ($window.FindName("ft_Hyp").IsChecked) { Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart }
    if ($window.FindName("ft_Sand").IsChecked) { Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -NoRestart }
    if ($window.FindName("ft_WSL").IsChecked) { Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart }
    Log "Features installees."
})

$window.FindName("btnPanel").Add_Click({ Start-Process "control" })
$window.FindName("btnNet").Add_Click({ Start-Process "ncpa.cpl" })
$window.FindName("btnSound").Add_Click({ Start-Process "mmsys.cpl" })
$window.FindName("btnWUP").Add_Click({ Stop-Service wuauserv; Remove-Item C:\Windows\SoftwareDistribution -Recurse -Force; Start-Service wuauserv })
$window.FindName("btnResetNet").Add_Click({ Start-Process cmd "/c netsh winsock reset & ipconfig /flushdns" -Verb RunAs })
$window.FindName("btnSFC").Add_Click({ Start-Process cmd "/k sfc /scannow" -Verb RunAs })

$window.ShowDialog() | Out-Null
