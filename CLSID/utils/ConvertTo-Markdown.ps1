Function ConvertTo-Markdown {
    <#
    .Synopsis
       Converts a PowerShell object to a Markdown table.
    .EXAMPLE
       $data | ConvertTo-Markdown
    .EXAMPLE
       ConvertTo-Markdown($data)

    From: https://gist.github.com/mac2000/86150ab43cfffc5d0eef#gistcomment-2067544
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [PSObject[]]$collection
    )

    Begin {
        $items = @()
        $columns = [ordered]@{}
    }

    Process {
        ForEach($item in $collection) {
            $items += $item

            $item.PSObject.Properties | %{

              if (([string]::IsNullOrEmpty($_.Value))){
                $_.Value = "-"
              }

                if(-not $columns.Contains($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                    $columns[$_.Name] = $_.Value.ToString().Length
                }
            }
        }
    }

    End {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }

        $header = @()
        ForEach($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key
        }
        $header -join ' | '

        $separator = @()
        ForEach($key in $columns.Keys) {
            $separator += '-' * $columns[$key]
        }
        $separator -join ' | '

        ForEach($item in $items) {
            $values = @()
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key)
            }
            $values -join ' | '
        }
    }
}
