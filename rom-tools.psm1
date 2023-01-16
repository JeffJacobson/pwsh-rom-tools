New-Variable -Name noInfoNameRe -Value ([regex]'(?inx)
    ^(
        (?<stuff>
            .+
        )\s-\s
    )?
    # Capture the company name
    # Using non-greedy so as to not catch extra " - " separated part 
    # e.g., only the "Sega" part of "Sega - Master System - Mark III"
    (?<Company>.+?)
    \s-\s
    # Capture the name of the console, computer, etc.
    (?<System>
        .+
        # (\s-\s.+)?
    )
    \s+
    \(
        (
            (?<Year>\d{4})
            (?<Month>\d{2})
            (?<Day>\d{2})
        )-(
            (?<Hour>\d{2})
            (?<Minute>\d{2})
            (?<Second>\d{2})
        )
    \)
    (\s(?<Extra>.+))?') -Option Constant

New-Variable -Name zipFileRe -Value ([regex]'(?inx)
    ^(
        (?<stuff>
            .+
        )\s-\s
    )?
    # Capture the company name
    # Using non-greedy so as to not catch extra " - " separated part 
    # e.g., only the "Sega" part of "Sega - Master System - Mark III"
    (?<Company>.+?)
    \s-\s
    # Capture the name of the console, computer, etc.
    (?<System>
        .+
        # (\s-\s.+)?
    )
    \s+
    \(
        (
            (?<Year>\d{4})
            (?<Month>\d{2})
            (?<Day>\d{2})
        )-(
            (?<Hour>\d{2})
            (?<Minute>\d{2})
            (?<Second>\d{2})
        )
    \)
    (\s(?<Extra>.+))?
    (?=\.zip)') -Option Constant -Description 'Matches the filenames of ZIPs downloaded from Internet Archive'

New-Variable dateGroupNames -Value (@(
        'Year',
        'Month',
        'Day',
        'Hour',
        'Minute',
        'Second'
    )) -Option Constant -Description 'The names of the groups in zipFileRe that are part of the date.'


function Get-InfoFromName {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    
    $match = $noInfoNameRe.Match($Name)
    # Write-Debug "Match for `"$Name`" is `"$match`""
    if (-not $match.Success) {
        throw [System.FormatException]::new("Incorrect format: $Name")
    }
    
    $dateParts = New-Object System.Collections.Generic.List[int]
    $outputHash = [ordered]@{}
    foreach ($group in $match.Groups) {
        # Skip the first group, which is the entire match.
        if ($group.Name -eq '0') {
            continue
        }
        # if part of the date, parse to int and add to date parts list.
        if ($group.Name -in $dateGroupNames) {
            $dateParts.Add([int]::Parse($group.Value))
        }
        # If not a date part, add to output hash.
        else {
            $outputHash.Add($group.Name, $group.Value)
        }
    }

    # Add Date and File to output hashtable.
    $outputHash.Add('Date', (New-Object datetime -ArgumentList $dateParts))
    # $outputHash.Add('File', $_)

    return [PSCustomObject]$outputHash
}

<#
.SYNOPSIS
    Gets a list of all the No-Intro ROM ZIP files downloaded from Internet Archive.
.INPUTS
    ZipFilePath
        See the Get-ChildItem's Path parameter.
.OUTPUTS
    Objects with Company, System, Extra, Date, and File properties.
.EXAMPLE
    PS C:\> Get-ZipFiles -ErrorAction Inquire | Format-Table -GroupBy Company -Property System,Date,Extra,File -AutoSize

       Company: Nichibutsu
    
    System    Date                   Extra File
    ------    ----                   ----- ----
    My Vision 11/22/2021 12:10:19 PM       C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nichibutsu - My Vision (20211122-121019).zip
    
       Company: Nintendo
    
    System                            Date                  Extra         File
    ------                            ----                  -----         ----
    amiibo                            11/13/2021 4:04:58 AM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - amiibo (20211113-040458).zip
    Family Computer Disk System (FDS) 2/16/2022 2:14:27 PM   [unheadered] C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Family Computer Disk System (FDS) (20220…
    Game & Watch                      12/28/2021 7:58:57 AM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game & Watch (20211228-075857).zip
    Game Boy                          3/6/2022 10:12:28 PM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game Boy (20220306-221228).zip
    Game Boy Advance (Multiboot)      2/12/2022 2:56:07 AM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game Boy Advance (Multiboot) (20220212-0…
    Game Boy Color                    3/10/2022 8:37:43 PM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game Boy Color (20220310-203743).zip
    Mario no Photopi SmartMedia       5/14/2021 9:00:46 AM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Mario no Photopi SmartMedia (20210514-09…
    Nintendo 64DD                     10/19/2021 1:05:56 PM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Nintendo 64DD (20211019-130556).zip
    Nintendo Entertainment System     3/10/2022 12:55:08 AM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Nintendo Entertainment System (20220310-…
    Play-Yan                          1/13/2021 9:29:36 AM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Play-Yan (20210113-092936).zip
    Pokemon Mini                      2/15/2022 10:30:58 PM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Pokemon Mini (20220215-223058).zip
    Satellaview                       3/1/2022 11:13:23 AM                C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Satellaview (20220301-111323).zip
    Sufami Turbo                      5/17/2021 10:13:04 PM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Sufami Turbo (20210517-221304).zip
    Virtual Boy                       11/25/2021 7:27:51 PM               C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Virtual Boy (20211125-192751).zip
    
       Company: Philips
    
    System    Date                  Extra File
    ------    ----                  ----- ----
    Videopac+ 2/23/2012 12:00:00 AM       C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Philips - Videopac+ (20120223-000000).zip
.EXAMPLE
    PS C:> Get-ZipFiles | Group-Object -Property Company

    Count Name                      Group
    ----- ----                      -----
        1 ACT                       {@{Company=ACT; System=Apricot PC Xi; Extra=; Date=11/25/2021 4:56:29 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\ACT - Apri…
        2 APF                       {@{Company=APF; System=Imagination Machine; Extra=; Date=12/13/2021 12:53:23 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\APF…
        8 Apple                     {@{Company=Apple; System=I; Extra=; Date=12/13/2021 12:59:55 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Apple - I (20211213…
        6 Atari                     {@{Company=Atari; System=2600; Extra=; Date=12/6/2021 1:19:45 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Atari - 2600 (2021…
        2 Bally                     {@{Company=Bally; System=Astrocade; Extra=; Date=11/24/2021 8:13:56 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bally - Astr…
        3 Bandai                    {@{Company=Bandai; System=Design Master Denshi Mangajuku; Extra=; Date=11/24/2021 1:27:45 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Ro…
        1 Benesse                   {@{Company=Benesse; System=Pocket Challenge W; Extra=; Date=3/7/2021 9:50:29 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Ben…
        1 Bit Corporation           {@{Company=Bit Corporation; System=Gamate; Extra=; Date=3/6/2022 12:31:06 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bit Co…
        2 Casio                     {@{Company=Casio; System=Loopy; Extra=; Date=3/12/2022 2:14:01 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Casio - Loopy (20…
        1 Coleco                    {@{Company=Coleco; System=ColecoVision; Extra=; Date=12/2/2021 3:52:30 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Coleco - …
        5 Commodore                 {@{Company=Commodore; System=Commodore 64; Extra=; Date=2/16/2021 11:26:16 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Commo…
        1 Emerson                   {@{Company=Emerson; System=Arcadia 2001; Extra=; Date=11/24/2008 7:33:19 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Emerson…
        1 Entex                     {@{Company=Entex; System=Adventure Vision; Extra=; Date=11/25/2008 3:14:50 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Entex…
        2 Epoch                     {@{Company=Epoch; System=Game Pocket Computer; Extra=; Date=11/22/2021 2:12:48 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\E…
        1 Fairchild                 {@{Company=Fairchild; System=Channel F; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Fairchil…
        1 Funtech                   {@{Company=Funtech; System=Super Acan; Extra=; Date=1/11/2020 4:41:09 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Funtech - …
        2 GamePark                  {@{Company=GamePark; System=GP2X; Extra=; Date=1/7/2022 11:51:26 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\GamePark - GP2X…
        1 GCE                       {@{Company=GCE; System=Vectrex; Extra=; Date=9/8/2017 9:12:36 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\GCE - Vectrex (201…
        1 Hartung                   {@{Company=Hartung; System=Game Master; Extra=; Date=10/12/2021 6:47:12 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Hartung …
        1 Interton                  {@{Company=Interton; System=VC 4000; Extra=; Date=11/22/2021 1:58:10 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Interton - …
        1 Konami                    {@{Company=Konami; System=Picno; Extra=; Date=11/21/2020 5:22:49 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Konami - Picno …
        1 LeapFrog                  {@{Company=LeapFrog; System=LeapPad; Extra=; Date=4/1/2019 3:53:14 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\LeapFrog - Le…
        1 Magnavox                  {@{Company=Magnavox; System=Odyssey 2; Extra=; Date=7/20/2020 10:16:03 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Magnavox …
        1 Mattel                    {@{Company=Mattel; System=Intellivision; Extra=; Date=9/22/2021 4:56:56 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Mattel -…
        2 Microsoft                 {@{Company=Microsoft; System=MSX; Extra=; Date=10/22/2020 7:15:28 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Microsoft - MS…
        2 NEC                       {@{Company=NEC; System=PC Engine - TurboGrafx 16; Extra=; Date=1/6/2022 7:31:48 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\…
        1 Nichibutsu                {@{Company=Nichibutsu; System=My Vision; Extra=; Date=11/22/2021 12:10:19 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nichib…
       14 Nintendo                  {@{Company=Nintendo; System=amiibo; Extra=; Date=11/13/2021 4:04:58 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - a…
        1 Philips                   {@{Company=Philips; System=Videopac+; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Philips - …
        1 RCA                       {@{Company=RCA; System=Studio II; Extra=; Date=2/1/2020 12:18:22 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\RCA - Studio II…
        5 Sega                      {@{Company=Sega; System=32X; Extra=; Date=1/6/2022 6:40:49 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Sega - 32X (20220106-…
        1 Seta                      {@{Company=Seta; System=Aleck64 (BigEndian); Extra=; Date=3/2/2022 4:29:20 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Seta …
        1 SNK                       {@{Company=SNK; System=Neo Geo Pocket; Extra=; Date=12/27/2021 8:59:45 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\SNK - Neo…
        1 Tiger                     {@{Company=Tiger; System=Game.com; Extra=; Date=11/25/2008 11:09:50 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Tiger - Game…
        3 Toshiba                   {@{Company=Toshiba; System=Pasopia (BIN); Extra=; Date=11/26/2021 6:25:34 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Toshib…
        1 VTech                     {@{Company=VTech; System=CreatiVision; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\VTech - C…
        1 Watara                    {@{Company=Watara; System=Supervision; Extra=; Date=2/8/2022 1:47:17 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Watara - Su…
        1 Welback                   {@{Company=Welback; System=Mega Duck; Extra=; Date=2/26/2022 10:44:51 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Welback - …
        1 Yamaha                    {@{Company=Yamaha; System=Copera; Extra=; Date=11/25/2021 5:15:49 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Yamaha - Coper…
.EXAMPLE
    PS C:\> Get-ZipFiles | Group-Object -Property Company | Format-Table -Wrap -AutoSize

    Count Name            Group
    ----- ----            -----
        1 ACT             {@{Company=ACT; System=Apricot PC Xi; Extra=; Date=11/25/2021 4:56:29 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\ACT - Apricot PC Xi
                          (20211125-165629).zip}}
        2 APF             {@{Company=APF; System=Imagination Machine; Extra=; Date=12/13/2021 12:53:23 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\APF -
                          Imagination Machine (20211213-125323).zip}, @{Company=APF; System=MP-1000; Extra=; Date=12/13/2021 12:58:03 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\APF - MP-1000 (20211213-125803).zip}}rom  
        8 Apple           {@{Company=Apple; System=II (WOZ); Extra=; Date=2/26/2022 4:36:20 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Apple - II (WOZ)
                          (20220226-043620).zip}, @{Company=Apple; System=I; Extra=; Date=12/13/2021 12:59:55 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Apple
                          - I (20211213-125955).zip}, @{Company=Apple; System=II (A2R); Extra=; Date=2/26/2022 4:36:20 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Apple - II (A2R) (20220226-043620).zip}, @{Company=Apple; System=II Plus (A2R); Extra=;
                          Date=12/27/2021 6:16:30 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Apple - II Plus (A2R) (20211227-061630).zip}…}
        6 Atari           {@{Company=Atari; System=2600; Extra=; Date=12/6/2021 1:19:45 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Atari - 2600
                          (20211206-131945).zip}, @{Company=Atari; System=5200; Extra=; Date=2/25/2022 7:26:11 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Atari
                          - 5200 (20220225-072611).zip}, @{Company=Atari; System=7800; Extra=; Date=9/20/2021 6:55:54 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Atari - 7800 (20210920-065554).zip}, @{Company=Atari; System=8-bit Family; Extra=;
                          Date=12/2/2021 5:10:03 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Atari - 8-bit Family (20211202-051003).zip}…}
        2 Bally           {@{Company=Bally; System=Astrocade; Extra=; Date=11/24/2021 8:13:56 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bally - Astrocade
                          (20211124-201356).zip}, @{Company=Bally; System=Astrocade (Tapes) (BIN); Extra=; Date=11/24/2021 6:56:28 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bally - Astrocade (Tapes) (BIN) (20211124-185628).zip}}
        3 Bandai          {@{Company=Bandai; System=Design Master Denshi Mangajuku; Extra=; Date=11/24/2021 1:27:45 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bandai - Design Master Denshi Mangajuku (20211124-132745).zip}, @{Company=Bandai;
                          System=Gundam RX-78; Extra=; Date=11/24/2021 1:35:20 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bandai - Gundam RX-78
                          (20211124-013520).zip}, @{Company=Bandai; System=WonderSwan; Extra=; Date=11/25/2021 7:16:00 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bandai - WonderSwan (20211125-191600).zip}}
        1 Benesse         {@{Company=Benesse; System=Pocket Challenge W; Extra=; Date=3/7/2021 9:50:29 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Benesse -
                          Pocket Challenge W (20210307-215029).zip}}
        1 Bit Corporation {@{Company=Bit Corporation; System=Gamate; Extra=; Date=3/6/2022 12:31:06 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Bit Corporation
                          - Gamate (20220306-123106).zip}}
        2 Casio           {@{Company=Casio; System=Loopy; Extra=; Date=3/12/2022 2:14:01 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Casio - Loopy
                          (20220312-141401).zip}, @{Company=Casio; System=PV-1000; Extra=; Date=1/9/2020 10:36:03 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Casio - PV-1000 (20200109-103603).zip}}
        1 Coleco          {@{Company=Coleco; System=ColecoVision; Extra=; Date=12/2/2021 3:52:30 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Coleco -
                          ColecoVision (20211202-035230).zip}}
        5 Commodore       {@{Company=Commodore; System=Commodore 64; Extra=; Date=2/16/2021 11:26:16 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Commodore -
                          Commodore 64 (20210216-232616).zip}, @{Company=Commodore; System=Commodore 64 (PP); Extra=; Date=12/4/2013 8:18:26 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Commodore - Commodore 64 (PP) (20131204-081826).zip}, @{Company=Commodore; System=Commodore 64
                          (Tapes); Extra=; Date=2/16/2021 11:19:40 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Commodore - Commodore 64 (Tapes)
                          (20210216-231940).zip}, @{Company=Commodore; System=Plus-4; Extra=; Date=1/5/2009 12:00:00 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Commodore - Plus-4 (20090105-000000).zip}…}
        1 Emerson         {@{Company=Emerson; System=Arcadia 2001; Extra=; Date=11/24/2008 7:33:19 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Emerson - Arcadia
                          2001 (20081124-193319).zip}}
        1 Entex           {@{Company=Entex; System=Adventure Vision; Extra=; Date=11/25/2008 3:14:50 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Entex -
                          Adventure Vision (20081125-031450).zip}}
        2 Epoch           {@{Company=Epoch; System=Game Pocket Computer; Extra=; Date=11/22/2021 2:12:48 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Epoch -
                          Game Pocket Computer (20211122-141248).zip}, @{Company=Epoch; System=Super Cassette Vision; Extra=; Date=11/23/2020 1:35:46 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Epoch - Super Cassette Vision (20201123-013546).zip}}
        1 Fairchild       {@{Company=Fairchild; System=Channel F; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Fairchild -
                          Channel F (20120223-000000).zip}}
        1 Funtech         {@{Company=Funtech; System=Super Acan; Extra=; Date=1/11/2020 4:41:09 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Funtech - Super Acan
                          (20200111-044109).zip}}
        2 GamePark        {@{Company=GamePark; System=GP2X; Extra=; Date=1/7/2022 11:51:26 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\GamePark - GP2X
                          (20220107-115126).zip}, @{Company=GamePark; System=GP32; Extra=; Date=2/24/2010 8:09:28 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\GamePark - GP32 (20100224-080928).zip}}
        1 GCE             {@{Company=GCE; System=Vectrex; Extra=; Date=9/8/2017 9:12:36 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\GCE - Vectrex
                          (20170908-211236).zip}}
        1 Hartung         {@{Company=Hartung; System=Game Master; Extra=; Date=10/12/2021 6:47:12 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Hartung - Game
                          Master (20211012-064712).zip}}
        1 Interton        {@{Company=Interton; System=VC 4000; Extra=; Date=11/22/2021 1:58:10 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Interton - VC 4000
                          (20211122-135810).zip}}
        1 Konami          {@{Company=Konami; System=Picno; Extra=; Date=11/21/2020 5:22:49 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Konami - Picno
                          (20201121-052249).zip}}
        1 LeapFrog        {@{Company=LeapFrog; System=LeapPad; Extra=; Date=4/1/2019 3:53:14 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\LeapFrog - LeapPad
                          (20190401-035314).zip}}
        1 Magnavox        {@{Company=Magnavox; System=Odyssey 2; Extra=; Date=7/20/2020 10:16:03 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Magnavox - Odyssey
                          2 (20200720-221603).zip}}
        1 Mattel          {@{Company=Mattel; System=Intellivision; Extra=; Date=9/22/2021 4:56:56 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Mattel -
                          Intellivision (20210922-165656).zip}}
        2 Microsoft       {@{Company=Microsoft; System=MSX; Extra=; Date=10/22/2020 7:15:28 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Microsoft - MSX
                          (20201022-071528).zip}, @{Company=Microsoft; System=MSX2; Extra=; Date=1/15/2019 6:30:03 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Microsoft - MSX2 (20190115-063003).zip}}
        2 NEC             {@{Company=NEC; System=PC Engine - TurboGrafx 16; Extra=; Date=1/6/2022 7:31:48 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\NEC - PC
                          Engine - TurboGrafx 16 (20220106-193148).zip}, @{Company=NEC; System=PC Engine SuperGrafx; Extra=; Date=9/5/2021 4:20:20 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\NEC - PC Engine SuperGrafx (20210905-042020).zip}}
        1 Nichibutsu      {@{Company=Nichibutsu; System=My Vision; Extra=; Date=11/22/2021 12:10:19 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nichibutsu - My
                          Vision (20211122-121019).zip}}
       14 Nintendo        {@{Company=Nintendo; System=amiibo; Extra=; Date=11/13/2021 4:04:58 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - amiibo
                          (20211113-040458).zip}, @{Company=Nintendo; System=Family Computer Disk System (FDS); Extra= [unheadered]; Date=2/16/2022 2:14:27 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Family Computer Disk System (FDS) (20220216-141427) [unheadered].zip},
                          @{Company=Nintendo; System=Game & Watch; Extra=; Date=12/28/2021 7:58:57 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game &
                          Watch (20211228-075857).zip}, @{Company=Nintendo; System=Game Boy; Extra=; Date=3/6/2022 10:12:28 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Nintendo - Game Boy (20220306-221228).zip}…}
        1 Philips         {@{Company=Philips; System=Videopac+; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Philips - Videopac+
                          (20120223-000000).zip}}
        1 RCA             {@{Company=RCA; System=Studio II; Extra=; Date=2/1/2020 12:18:22 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\RCA - Studio II
                          (20200201-121822).zip}}
        5 Sega            {@{Company=Sega; System=32X; Extra=; Date=1/6/2022 6:40:49 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Sega - 32X
                          (20220106-184049).zip}, @{Company=Sega; System=Beena; Extra=; Date=1/27/2020 1:52:09 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Sega
                          - Beena (20200127-135209).zip}, @{Company=Sega; System=Game Gear; Extra=; Date=1/10/2022 12:05:45 AM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Sega - Game Gear (20220110-000545).zip}, @{Company=Sega; System=Master System - Mark III;
                          Extra=; Date=2/3/2022 9:16:16 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Sega - Master System - Mark III (20220203-091616).zip}…}
        1 Seta            {@{Company=Seta; System=Aleck64 (BigEndian); Extra=; Date=3/2/2022 4:29:20 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Seta - Aleck64
                          (BigEndian) (20220302-042920).zip}}
        1 SNK             {@{Company=SNK; System=Neo Geo Pocket; Extra=; Date=12/27/2021 8:59:45 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\SNK - Neo Geo
                          Pocket (20211227-205945).zip}}
        1 Tiger           {@{Company=Tiger; System=Game.com; Extra=; Date=11/25/2008 11:09:50 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Tiger - Game.com
                          (20081125-110950).zip}}
        3 Toshiba         {@{Company=Toshiba; System=Pasopia (BIN); Extra=; Date=11/26/2021 6:25:34 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Toshiba -
                          Pasopia (BIN) (20211126-182534).zip}, @{Company=Toshiba; System=Pasopia (WAV); Extra=; Date=11/26/2021 6:25:34 PM;
                          File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Toshiba - Pasopia (WAV) (20211126-182534).zip}, @{Company=Toshiba; System=Visicom; Extra=;
                          Date=2/2/2020 12:09:58 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Toshiba - Visicom (20200202-120958).zip}}
        1 VTech           {@{Company=VTech; System=CreatiVision; Extra=; Date=2/23/2012 12:00:00 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\VTech -
                          CreatiVision (20120223-000000).zip}}
        1 Watara          {@{Company=Watara; System=Supervision; Extra=; Date=2/8/2022 1:47:17 AM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Watara - Supervision
                          (20220208-014717).zip}}
        1 Welback         {@{Company=Welback; System=Mega Duck; Extra=; Date=2/26/2022 10:44:51 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Welback - Mega Duck
                          (20220226-224451).zip}}
        1 Yamaha          {@{Company=Yamaha; System=Copera; Extra=; Date=11/25/2021 5:15:49 PM; File=C:\Emulation\ROMs\no-intro_2022-03-15\No-intro-Romset-2022\Yamaha - Copera
                          (20211125-171549).zip}}
#>
function Get-ZipFiles {
    [CmdletBinding()]
    param (
        # Path to ZIP files
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to ZIP files')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $ZipFilePath = (Get-Location)
    )

    Get-ChildItem $ZipFilePath -Filter *.zip | ForEach-Object -Parallel {
        $match = ($USING:zipFileRe).Match($_.Name)
        $currentFile = $_
        if ($match.Success) {
            $dateParts = New-Object System.Collections.Generic.List[int]
            $outputHash = [ordered]@{}
            foreach ($group in $match.Groups) {
                # Skip the first group, which is the entire match.
                if ($group.Name -eq '0') {
                    continue
                }
                # if part of the date, parse to int and add to date parts list.
                if ($group.Name -in $USING:dateGroupNames) {
                    $dateParts.Add([int]::Parse($group.Value))
                }
                # If not a date part, add to output hash.
                else {
                    $outputHash.Add($group.Name, $group.Value)
                }
            }

            # Add Date and File to output hashtable.
            $outputHash.Add('Date', (New-Object datetime -ArgumentList $dateParts))
            $outputHash.Add('File', $_)

            $destinationPath = $match.Value
            if ($Unzip) {
                Expand-Archive -LiteralPath $currentFile -DestinationPath $destinationPath -WhatIf
            }

            [PSCustomObject]$outputHash
        }
    }
}

function Get-NonMatchingZipFiles {
    [CmdletBinding()]
    param (
        # Path to ZIP files
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to ZIP files')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $ZipFilePath = '.'
    )
    
    Get-ChildItem $ZipFilePath -Filter *.zip | Where-Object -Property Name -NotMatch $zipFileRe
}