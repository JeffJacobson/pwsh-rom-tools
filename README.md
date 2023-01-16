# PowerShell tools for use with ROMs Archives

This module was created for use with ZIP archives named in the manner specified by [No-Intro].

## Use

1. Import the module
    ```pwsh
    Import-Module .\rom-tools.psm1
    ```
2. Get list of commands
    ```pwsh
    Get-Command -Module rom-tools -Syntax
    ```
3. Run `Get-Help` for the command you want to use
    ```pwsh
    Get-Help Get-ZipFiles -Full | Out-Host -Paging
    ```

[No-Intro]:https://no-intro.org/
[No-Intro XSD]:https://datomatic.no-intro.org/stuff/schema_nointro_datfile_v2.xsd
[No-Intro Wiki]:https://wiki.no-intro.org