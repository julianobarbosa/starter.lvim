#!/bin/bash

/bin/pwsh -NoLogo -NoProfile -Command "/opt/microsoft/PowerShellEditorServices/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath /opt/microsoft/PowerShellEditorServices/PowerShellEditorServices/ -LogPath /home/barbosa/tmp/logs.log -SessionDetailsPath /home/barbosa/tmp/session.json -FeatureFlags @() -AdditionalModules @() -HostName 'My Client' -HostProfileId myclient -HostVersion 1.0.0 -LogLevel Normal" &
