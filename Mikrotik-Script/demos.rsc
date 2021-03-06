# Prueba de Mikrotik Script
:foreach i in=[ip hotspot user find (uptime=0 && uptime < 10h)] do={
	log warning [/ip hotspot user get value-name=uptime $i]
}

:local contador;
:foreach i in=[/interface wireless registration-table find] do={
	$contador = $contador + 1;
};
:put $contador;


:foreach i in=[/interface wireless registration-table find (signal-strength < 70)] do={
	log info [/interface wireless registration-table get value-name=radio-name $i]
};


# Loop while
:global contador 0;
:while ($contador <= 5) do={
	:set $contador ($contador+1);
	:put $contador;
};
:set $contador 0;

# Buscar todas los usuarios que tengan una señal entre -30dBm ... -60dBm

:foreach i in=[/interface wireless registration-table find (signal-strength > -30 && signal-strength < -65)] do={
	:log warning $i;
};

# Imprimir la señal recibida 
# 
:foreach i in=[/interface wireless registration-table find] do={ log warning [/interface wireless registration-table get value-name=uptime $i]};



# Buscar las vesiones de los clientes que no esten actualizados
:global versionReciente 6.47.1;
:log info "";
:foreach i in=[/interface wireless registration-table find (routeros-version < $versionReciente)] do={
	:local nombre [/interface wireless registration-table get value-name=radio-name $i];
	log warning $nombre;
};



######
######
######


#!rsc
# RouterOS script: check-routeros-update
# Copyright (c) 2013-2020 Christian Hesse <mail@eworm.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# check for RouterOS update, send notification and/or install
# https://git.eworm.de/cgit/routeros-scripts/about/doc/check-routeros-update.md

:global Identity;
:global SafeUpdateUrl;
:global SafeUpdatePatch;
:global SentRouterosUpdateNotification;

:global DeviceInfo;
:global LogPrintExit;
:global ScriptFromTerminal;
:global SendNotification;
:global SymbolForNotification;
:global VersionToNum;

:local DoUpdate do={
  :if ([ / system script print count-only where name="packages-update" ] > 0) do={
    / system script run packages-update;
  } else={
    / system package update install without-paging;
  }
  :error "Waiting for system to reboot.";
}

:if ([ / system package print count-only where name="wireless" disabled=no ] > 0) do={
  :if ([ / interface wireless cap get enabled ] = true && \
      [ / caps-man manager get enabled ] = false) do={
    $LogPrintExit error "System is managed by CAPsMAN, not checking." true;
  }
}

:if ([ / system scheduler print count-only where name="reboot-for-update" ] > 0) do={
  :error "A reboot for update is already scheduled.";
}

/ system package update check-for-updates without-paging;
:local Update [ / system package update get ];

:if ([ :len ($Update->"latest-version") ] = 0) do={
  $LogPrintExit warning "An empty string is not a valid version." true;
}

:local NumInstalled [ $VersionToNum ($Update->"installed-version") ];
:local NumLatest [ $VersionToNum ($Update->"latest-version") ];

:if ($NumInstalled < $NumLatest) do={
  :if ($SafeUpdatePatch = true && ($NumInstalled & 0xffff0000) = ($NumLatest & 0xffff0000)) do={
    $LogPrintExit info ("Version " . $Update->"latest-version" . " is a patch release, updating...") false;
    $SendNotification ([ $SymbolForNotification "sparkles" ] . "RouterOS update") \
        ("Version " . $Update->"latest-version" . " is a patch update for " . $Update->"channel" . \
        ", updating on " . $Identity . "...") "" "true";
    $DoUpdate;
  }

  :if ([ :len $SafeUpdateUrl ] > 0) do={
    :local Result;
    :do {
      :set Result [ / tool fetch check-certificate=yes-without-crl \
          ($SafeUpdateUrl . $Update->"channel" . "?installed=" . $Update->"installed-version" . \
          "&latest=" . $Update->"latest-version") output=user as-value ];
    } on-error={
      $LogPrintExit warning ("Failed receiving safe version for " . $Update->"channel" . ".") false;
    }
    :if ($Result->"status" = "finished" && $Result->"data" = $Update->"latest-version") do={
      $LogPrintExit info ("Version " . $Update->"latest-version" . " is considered safe, updating...") false;
      $SendNotification ([ $SymbolForNotification "sparkles" ] . "RouterOS update") \
          ("Version " . $Update->"latest-version" . " is considered safe for " . $Update->"channel" . \
          ", updating on " . $Identity . "...") "" "true";
      $DoUpdate;
    }
  }

  :if ([ $ScriptFromTerminal "check-routeros-update" ] = true) do={
    :put ("Do you want to install RouterOS version " . $Update->"latest-version" . "? [y/N]");
    :if (([ :terminal inkey timeout=60 ] % 32) = 25) do={
      $DoUpdate;
    } else={
      :put "Canceled...";
    }
  }

  :if ($SentRouterosUpdateNotification = $Update->"latest-version") do={
    $LogPrintExit info ("Already sent the RouterOS update notification for version " . \
        $Update->"latest-version" . ".") true;
  }

  $SendNotification ([ $SymbolForNotification "sparkles" ] . "RouterOS update") \
    ("A new RouterOS version " . ($Update->"latest-version") . \
      " is available for " . $Identity . ".\n\n" . \
      [ $DeviceInfo ] . "\n\n" . \
      "https://mikrotik.com/download/changelogs/" . $Update->"channel" . "-release-tree") \
    "" "true";
  :set SentRouterosUpdateNotification ($Update->"latest-version");
}

:if ($NumInstalled > $NumLatest) do={
  :if ($SentRouterosUpdateNotification = $Update->"latest-version") do={
    $LogPrintExit info ("Already sent the RouterOS downgrade notification for version " . \
        $Update->"latest-version" . ".") true;
  }

  $SendNotification ([ $SymbolForNotification "warning-sign" ] . "RouterOS version") \
    ("A different RouterOS version " . ($Update->"latest-version") . \
      " is available for " . $Identity . ", but it is a downgrade.\n\n" . \
      [ $DeviceInfo ] . "\n\n" . \
      "https://mikrotik.com/download/changelogs/" . $Update->"channel" . "-release-tree") \
    "" "true";
  $LogPrintExit info ("A different RouterOS version " . ($Update->"latest-version") . \
    " is available for downgrade.") false;
  :set SentRouterosUpdateNotification ($Update->"latest-version");
}