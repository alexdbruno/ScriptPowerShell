
#Este script PowerShell foi desenvolvido para automatizar o processo de envio de arquivos via SFTP
#Garantindo que os arquivos sejam armazenados de forma organizada e segura.
# Carregar a biblioteca WinSCP
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Definir opções de sessão com autenticação por chave SSH
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "sftp.example.com"  # Substituir pelo hostname real
    UserName = "usuario_sftp"      # Substituir pelo nome de usuário real
    SshPrivateKeyPath = "C:\Caminho\Para\Chave_Privada.ppk"  # Caminho da chave privada
    SshHostKeyFingerprint = "ssh-rsa-xxxxx"  # Fingerprint do host SFTP
}

$session = New-Object WinSCP.Session

# Definir caminho do log
$LogFile = "C:\Caminho\Para\log.txt"
function WriteToLog($Message) {
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" | Out-File -Append -FilePath $LogFile
}

try {
    # Conectar ao SFTP
    $session.Open($sessionOptions)
    WriteToLog "Conexão SFTP estabelecida."

    # Definir caminhos locais e remotos
    $LocalPath = "C:\Caminho\Para\Arquivos\*.txt"
    $RemotePath = "/DELIVERY/"
    $BackupBasePath = "C:\Backup"
    
    # Enviar arquivos para o SFTP
    $session.PutFiles($LocalPath, $RemotePath).Check()
    WriteToLog "Arquivos enviados para o SFTP."
    
    # Processar arquivos localmente
    Get-ChildItem -Path $LocalPath | ForEach-Object {
        $Arquivo = $_.FullName
        $NomeArquivo = $_.Name
        
        # Criar estrutura de diretórios com ano/mês/dia
        $DataAtual = Get-Date
        $BackupPath = "$BackupBasePath\$($DataAtual.Year)\$($DataAtual.Month)\$($DataAtual.Day)"
        if (!(Test-Path $BackupPath)) { New-Item -Path $BackupPath -ItemType Directory -Force }
        
        # Compactar arquivo
        $ZipFile = "$BackupPath\$($DataAtual.ToString('HHmm'))_$NomeArquivo.zip"
        Compress-Archive -Path $Arquivo -DestinationPath $ZipFile
        WriteToLog "Arquivo $NomeArquivo compactado para $ZipFile."
        
        # Remover arquivo original após compactação
        Remove-Item -Path $Arquivo -Force
        WriteToLog "Arquivo original $NomeArquivo removido."
    }
} catch {
    WriteToLog "Erro: $_"
} finally {
    # Encerrar conexão SFTP
    $session.Dispose()
    WriteToLog "Conexão SFTP encerrada."
}
