function Show-JobProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Job[]]
        $Job
    )

    Process {
        $scroll = "/-\|/-\|"
        $idx = 0

        $origpos = $host.UI.RawUI.CursorPosition
        $origpos.Y += 1

        while (($job.State -eq "Running") -and ($Job.State -ne "NotStarted"))
        {
            $host.UI.RawUI.CursorPosition = $origpos
            Write-Host $scroll[$idx] -NoNewline
            $idx++
            if ($idx -ge $scroll.Length)
            {
                $idx = 0
            }
            Start-Sleep -Milliseconds 100
        }
        # It's over - clear the activity indicator.
        $host.UI.RawUI.CursorPosition = $origpos
        Write-Host ' '
    }
}