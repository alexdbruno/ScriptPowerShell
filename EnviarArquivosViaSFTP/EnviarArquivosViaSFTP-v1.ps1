#Este script PowerShell foi desenvolvido para automatizar o processo de envio de arquivos via SFTP
#Garantindo que os arquivos sejam armazenados de forma organizada e segura.
#Linguagem PowerShell

# Carrega a biblioteca do WinSCP para permitir a conexão SFTP
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Configuração da sessão SFTP
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp  # Define o protocolo como SFTP
    HostName = "seu-servidor-sftp.com"  # Endereço do servidor SFTP
    UserName = "seu-usuario"  # Nome do usuário para login
    Password = "sua-senha"  # Senha de acesso (não recomendado por segurança)
    SshHostKeyFingerprint = "ssh-rsa-xxxxxxxxxx"  # Impressão digital da chave SSH do servidor
}

# Criação da sessão WinSCP
$session = New-Object WinSCP.Session

# Definição do caminho do arquivo de log
$LogFile = "D:\Caminho\para\log.txt"

# Função para registrar mensagens no log
function WriteToLog($Message) {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # Obtém a data e hora atual
    $LogMessage = "[$TimeStamp] $Message"  # Formata a mensagem do log
    Add-Content -Path $LogFile -Value $LogMessage  # Adiciona a mensagem ao arquivo de log
}

try {
    # Estabelece a conexão com o servidor SFTP
    $session.Open($sessionOptions)
    WriteToLog "Conexão SFTP estabelecida com sucesso."

    # Faz o upload de todos os arquivos .txt para o diretório remoto
    $session.PutFiles("\\Caminho\local\*.txt", "/DELIVERY/").Check()
    
    # Obtém a lista de arquivos .txt na pasta local
    $ListItens = Get-Item -Path "\\Caminho\local\*.txt"
    
    # Define o caminho base onde os arquivos serão armazenados após a movimentação
    $Caminho = "\\Caminho\Backup\AnoAtual"
    
    # Define o caminho da pasta de origem dos arquivos
    $CaminhoOrigem = "\\Caminho\local"
    
    # Obtém a lista de pastas dentro do diretório de backup do ano atual
    $Mes = Get-ChildItem -Path $Caminho
    
    foreach ($List in $ListItens) {
        # Obtém a data atual e formata os valores necessários
        $Date = Get-Date
        $DateStr = '{0:yyyyMMdd HHmm}' -f $Date
        $DateMonth = '{0:MM}' -f $Date
        $DateDay = '{0:dd}' -f $Date
        $DateHour = '{0:HHmm}' -f $Date
        
        $Name = $List.Name  # Nome do arquivo original
        $NameNew = $Name  # Inicializa o nome do arquivo a ser compactado
        
        # Obtém a lista de diretórios do mês dentro do backup do ano
        $Dia = Get-ChildItem -Path "$Caminho\$DateMonth"

        # Verifica se já existe a pasta do mês no backup
        if ($Mes.Name -eq $DateMonth) {
            # Verifica se já existe a pasta do dia
            if ($Dia.Name -eq $DateDay) {
                $NameNew = $NameNew -replace ".txt", ".zip"  # Altera a extensão para .zip
                Compress-Archive -Path "$CaminhoOrigem\$Name" -DestinationPath "$Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
                WriteToLog "Arquivo $Name compactado com sucesso."
                Remove-Item -Path "$CaminhoOrigem\$Name"  # Remove o arquivo original após compactação
                WriteToLog "Arquivo $Name movido para $Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
            } else {
                New-Item -Path "$Caminho\$DateMonth" -Name "$DateDay" -ItemType Directory  # Cria a pasta do dia
                $NameNew = $NameNew -replace ".txt", ".zip"
                Compress-Archive -Path "$CaminhoOrigem\$Name" -DestinationPath "$Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
                WriteToLog "Arquivo $Name compactado com sucesso."
                Remove-Item -Path "$CaminhoOrigem\$Name"
                WriteToLog "Arquivo $Name movido para $Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
            }
        } else {
            New-Item -Path "$Caminho" -Name "$DateMonth" -ItemType Directory  # Cria a pasta do mês
            New-Item -Path "$Caminho\$DateMonth" -Name "$DateDay" -ItemType Directory  # Cria a pasta do dia
            $NameNew = $NameNew -replace ".txt", ".zip"
            Compress-Archive -Path "$CaminhoOrigem\$Name" -DestinationPath "$Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
            WriteToLog "Arquivo $Name compactado com sucesso."
            Remove-Item -Path "$CaminhoOrigem\$Name"
            WriteToLog "Arquivo $Name movido para $Caminho\$DateMonth\$DateDay\$DateHour $NameNew"
        }
    }
}
catch {
    # Captura erros e escreve no log
    WriteToLog "Erro: $_"
}
finally {
    # Fecha a conexão SFTP e finaliza o script
    $session.Dispose()
    WriteToLog "Conexão SFTP encerrada."
}
