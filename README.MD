# Video Streaming server - Nginx RTMP/HLS

## Objetivo
Criar um servidor de mídia com NGINX e módulo RTMP. Nesse procedimento iremos receber stream via RTMP e converter para HLS com certificado SSL.

Os arquivos desse procedimento já foram editados para facilitar a configuração do servidor, sendo assim possivel testar o servidor após a finalização do procedimento.

## Pré requesitos

* Ubuntu 20.04


## Depêndencias

* $ sudo apt update
* $ sudo apt install nginx -y && apt install ffmpeg -y

## NodeJs
Instalação via repositório oficial do NodeJs, necessário para instalar o PM2 (Gerenciador de processos) que será necessário para gerenciar o script ffmpeg.

* cd ~
* curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
* sudo bash nodesource_setup.sh
* sudo apt install nodejs

Verifique a versão

* node -v 
* npm -v

Para que todos pacotes node funcione adequadamente, será necessário instalar o pacote build-essential.

* sudo apt install build-essential

Instale o pm2 com
* npm install -g pm2

## GitHub
Verifique a versão do git, quase necessite instale o git 
* git --version

Faça um clone do repositório
* git clone https://github.com/RodofoF/Documentation---Oficial.git

Habilite o script
* cd Documentation---Oficial
* chmod +x speedcast.sh

### Ajuste o firewall
Para visualizar as app liberadas em seu firewall
* $ sudo ufw app list

Caso necessite ativar o firewall
* $ sudo enable ufw

Caso necessite liberar algum tráfico, nesse exemplo estamos liberando o tráfico Nginx HTTPS que é referente a porta 443. Caso necessite receber o video rtmp de alguma fonte externa considere liberar a porta 1935 referente ao protocolo rtmp.

* $ sudo ufw allow 'Nginx HTTPS'
* $ sudo ufw allow 'Nginx HTTP'

### Verificação
Para verificar se o servidor foi instalado corretamente
* $ systemctl status nginx

Digite o ip do seu no browser, deve aparecer uma imagem como abaixo

![welcome Nginx](welcome.png)

## Modulo RTMP/HLS
* $ sudo apt update 
* $ sudo apt install libnginx-mod-rtmp

### Arquivo nginx.conf
O arquivo se encontra em **/etc/nginx/nginx.conf** exclua o arquivo padrão e crie um novo com as informações do **nginx.conf** nesse diretório.

### Arquivo rtmp
Crie um arquivo rtmp em **/etc/nginx/sites-available/rtmp** e copie as mesmas informações do arquivo rtmp nesse diretório.
Após criar o arquivo cria uma conexão com sites-enable
* ln -s /etc/nginx/sites-available/rtmp /etc/nginx/sites-enabled/rtmp

### Pasta para stream
Crie para armazenar os aquivos de stream, uma pasta com o comando:
* $ sudo mkdir /var/www/html/stream

## Certificado SSL - autoassinado

Para teste iremos gerar um certificado autoassinado para teste
* openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

Verifique se existe alguma falha
* nginx -t

Se você seguiu os passos anteriores a posição da chave já esta no módulo correto. Após isso reinicie seu servidor

É possivel verificar em:
* https://{seu_dominio}/hls/{chave}.m3u8

### Atualizando 

Após a atualização dos arquivos execute um reload e restart no servidor.

* $ sudo systemctl restart nginx.service
* $ sudo systemctl reload nginx.service


## FFmpeg

Para teste o script speedcast.sh está criado, direcionando um video para localhost. 
Execute o comando para dar previlégios ao script.

Após o privilégio execute o script com auxilio do pm2
pm2 start speedcast.sh

Para testar o servidor é necessário utilizar um software de stream como OBS ou utilizar ffmpeg diretamente no server. Para instalar:


O arquivo .mp4 está diponivel no diretório para auxiliar no teste.
* $ ffmpeg -stream_loop -1 -re -i speedcast.mp4 -c:v libx264 -c:a aac -f flv rtmp://127.0.0.1:1935/live/teste?pkt_size=1316

## Teste

Reinicie o servidor, se todos passos foram seguidos corretamentes nesse momento você deve ter um stream HLS/HTTPS

* https://{seu_dominio_ou_IP}/hls/{stream_key}.m3u8


## Usuário e senha

Para configurar usuário e senha do stream iremos utilizar a ferramenta **htpasswd** caso seja necessário instale ela no servidor.

* sudo htpasswd -c /etc/nginx/.htpasswd {insira_seu_usuário} 

Após executar o comando acima você irá inserir a senha para o usuário, caso deseje inserir mais usuários repita o comando.



## Certificado SSL - válido

* $ sudo apt install certbot python3-certbot-nginx

Para inserir um certificado iremos utilizar a Let's Encrypty. Através de um scrypt é possivel facilitar o processo. É importante que tenha um dominio publico com a porta 80 e 443 abertas para validar esse processo, caso contrário o scrypt irá apresentar um erro. Nesse exemplo iremos utilizar o dominio **cdn.speedcast.com.br** 
* $ sudo apt update
* $ sudo certbot --nginx -d cdn.speedcast.com.br

Substitua **cdn.speedcast.com.br** pelo seu domínio. O Certbot irá solicitar que você forneça um endereço de e-mail para recuperação de chave perdida e notificações sobre a renovação do certificado, e que você concorde com os Termos de Serviço.

Durante a execução, o Certbot irá automaticamente fazer uma verificação de desafio para validar que você controla o domínio, obtendo o certificado SSL e modificando a configuração do Nginx para usar o certificado.

Caso tenha seguido o passo **Certificado SSL - autoassinado** o Certbot irá substituir automaticamente os arquivos.

Os certificados Let's Encrypt são válidos por 90 dias, mas o Certbot configura a renovação automática por padrão. Para testar se a renovação está funcionando corretamente, você pode executar:
* $ sudo certbot renew --dry-run


