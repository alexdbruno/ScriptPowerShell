Este script PowerShell foi desenvolvido para automatizar o processo de envio de arquivos via SFTP, garantindo que os arquivos sejam armazenados de forma organizada e segura. Ele segue um fluxo estruturado que inclui as seguintes etapas:

**Estabelecimento de Conexão Segura:** Utiliza a biblioteca WinSCP para conectar-se a um servidor SFTP de destino e transferir arquivos de um diretório específico.

**Registro de Logs:** Todas as operações críticas, incluindo sucessos e falhas, são registradas em um arquivo de log para fins de auditoria e monitoramento.

**Envio de Arquivos:** Os arquivos com extensão .txt são enviados automaticamente para o servidor remoto.

**Organização Local dos Arquivos:** Após o envio, os arquivos são movidos para um diretório de backup estruturado por ano, mês e dia.

**Compressão dos Arquivos:** Para otimizar o armazenamento e evitar redundância, os arquivos enviados são compactados em formato .zip.

**Remoção de Arquivos Originais:** Após a compactação, os arquivos originais são removidos para liberar espaço e evitar duplicações.

**Cenários de Uso**
Este script é ideal para organizações que precisam automatizar o envio de arquivos para um servidor SFTP e manter um histórico organizado dos arquivos processados. Ele pode ser útil em casos como:

Empresas que trocam dados com parceiros externos e precisam enviar arquivos automaticamente para um repositório remoto.
Ambientes de integração de dados, onde logs, relatórios ou transações precisam ser transferidos regularmente.
Backup automatizado de arquivos, garantindo que uma cópia seja mantida em local seguro após a transferência.
Processos de ETL (Extract, Transform, Load), onde os arquivos são coletados, enviados e arquivados para posterior análise.

A implementação pode ser facilmente adaptada para diferentes estruturas de diretórios, tipos de arquivos e servidores SFTP, tornando o script flexível para diversos casos de uso corporativos.
