O Windows PowerShell
Copyright (C) Microsoft Corporation. Todos os direitos reservados.

Instale o PowerShell mais recente para obter novos recursos e aprimoramentos! https://aka.ms/PSWindows

PS C:\WINDOWS\system32> ssh paulo@xxx.xxx.xxx.xxx
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-100-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun Mar  1 05:47:05 PM UTC 2026

  System load:  0.0                Processes:             155
  Usage of /:   39.2% of 18.01GB   Users logged in:       1
  Memory usage: 23%                IPv4 address for eth0: 192.168.70.11
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

79 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Thu Feb 12 20:17:59 2026 from xxx.xxx.xxx.xxx
paulo@rh-gf-01:~$
paulo@rh-gf-01:~$
paulo@rh-gf-01:~$ sudo docker ps
[sudo] password for paulo:
CONTAINER ID   IMAGE                        COMMAND                  CREATED       STATUS          PORTS                                         NAMES
a4ae42840d88   mariadb:10.11                "docker-entrypoint.s…"   4 weeks ago   Up 15 minutes   0.0.0.0:3306->3306/tcp, [::]:3306->3306/tcp   orange-db
470f4f70ab11   orangehrm/orangehrm:latest   "docker-php-entrypoi…"   4 weeks ago   Up 15 minutes   0.0.0.0:8085->80/tcp, [::]:8085->80/tcp       orange-app
paulo@rh-gf-01:~$ docker exec -it <nome_do_container_orangehrm> php bin/console orangehrm:version
-bash: nome_do_container_orangehrm: No such file or directory
paulo@rh-gf-01:~$ docker exec -it orange-db mariadb -u root -p
Enter password:
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
paulo@rh-gf-01:~$ docker exec -it orange-db mariadb -u root -p
Enter password:
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
paulo@rh-gf-01:~$ sudo grep -i "MYSQL_ROOT_PASSWORD" /caminho/do/seu/docker-compose.yml
[sudo] password for paulo:
grep: /caminho/do/seu/docker-compose.yml: No such file or directory
paulo@rh-gf-01:~$ docker stop orange-db
orange-db
paulo@rh-gf-01:~$ docker run -d --name orange-db-safe --volumes-from orange-db mariadb:10.11 --skip-grant-tables
<REDACTED_SECRET>226af46f1192434dd4eb1be7
paulo@rh-gf-01:~$ docker exec -it orange-db-safe mariadb -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.11.15-MariaDB-ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> FLUSH PRIVILEGES;
ot'@'loQuery OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY '**********';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> exit;
Bye
paulo@rh-gf-01:~$ docker stop orange-db-safe && docker rm orange-db-safe
docker start orange-db
orange-db-safe
orange-db-safe
orange-db
paulo@rh-gf-01:~$
paulo@rh-gf-01:~$ docker exec -it orange-db mariadb -u root -p
Enter password:
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
paulo@rh-gf-01:~$ docker exec -it orange-db mariadb -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.11.15-MariaDB-ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> USE greenfield_hr; -- Nome do banco definido no PRJ005 [cite: 2]
ERROR 1049 (42000): Unknown database 'greenfield_hr'
oyees (MariaDB [(none)]>
MariaDB [(none)]> CREATE TABLE staging_employees (
    ->     FirstName      VARCHAR(100),
    ->     LastName       VARCHAR(100),
    ->     EmployeeID     VARCHAR(50),
H    -> AR(    Department     VARCHAR(100),
    ->     JobTitle       VARCHAR(100),
    ->     Salary         DECIMAL(15,2),
    ->     Email          VARCHAR(150),
    ->     SecurityGroup  VARCHAR(100)
    -> );
ERROR 1046 (3D000): No database selected
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS greenfield_hr; [cite: 2]
 2]Query OK, 1 row affected (0.001 sec)

    -> USE greenfield_hr; [cite: 2]
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '[cite: 2]
USE greenfield_hr' at line 1
    -> CREATE TABLE staging_employees (
    ->     FirstName      VARCHAR(100),
    ->     LastName       VARCHAR(100),
    ->     EmployeeID     VARCHAR(50),
    ->     Department     VARCHAR(100),
    ->     JobTitle       VARCHAR(100),
     DE    ->     Salary         DECIMAL(15,2),
    ->     Email          VARCHAR(150),
    ->     SecurityGroup  VARCHAR(100)
    -> ); [cite: 1, 3]
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '[cite: 2]
CREATE TABLE staging_employees (
    FirstName      VARCHAR(100),
 ...' at line 1
    -> USE greenfield_hr;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '[cite: 1, 3]
USE greenfield_hr' at line 1
MariaDB [(none)]>
MariaDB [(none)]>
MariaDB [(none)]>
MariaDB [(none)]>
MariaDB [(none)]> USE greenfield_hr;
Database changed
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> CREATE TABLE staging_employees (
    ->     FirstName      VARCHAR(100),
    ->     LastName       VARCHAR(100),
    ->     EmployeeID     VARCHAR(50),
    ->     Department     VARCHAR(100),
    ->     JobTitle       VARCHAR(100),
    ->     Salary         DECIMAL(15,2),
    ->     Email          VARCHAR(150),
    ->     SecurityGroup  VARCHAR(100)
    -> );
Query OK, 0 rows affected (0.014 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> DESC staging_employees;
+---------------+---------------+------+-----+---------+-------+
| Field         | Type          | Null | Key | Default | Extra |
+---------------+---------------+------+-----+---------+-------+
| FirstName     | varchar(100)  | YES  |     | NULL    |       |
| LastName      | varchar(100)  | YES  |     | NULL    |       |
| EmployeeID    | varchar(50)   | YES  |     | NULL    |       |
| Department    | varchar(100)  | YES  |     | NULL    |       |
| JobTitle      | varchar(100)  | YES  |     | NULL    |       |
| Salary        | decimal(15,2) | YES  |     | NULL    |       |
| Email         | varchar(150)  | YES  |     | NULL    |       |
| SecurityGroup | varchar(100)  | YES  |     | NULL    |       |
+---------------+---------------+------+-----+---------+-------+
8 rows in set (0.000 sec)

MariaDB [greenfield_hr]> INSERT INTO staging_employees (FirstName, LastName, EmployeeID, Department, JobTitle, Salary, Email, SecurityGroup) VALUES
    -> ('David','Vélez','FP001','Executive','CEO',48000,'david.velez@fiqueok.com.br','GRP_EXEC_BOARD'),
    -> ('André','Chaves','FP002','Executive','Chairman',42000,'andre.chaves@fiqueok.com.br','GRP_EXEC_FINANCE'),
    -> ('Luisa','Sotero','FP003','Executive','COO',39000,'luisa.sotero@fiqueok.com.br','GRP_EXEC_OPERATIONS'),
    -> natti','('Daniela','Binatti','FP004','Executive','CTO',44000,'daniela.binatti@fiqueok.com.br','GRP_EXEC_TECH'),
    -> ('Ricardo','Guerra','FP005','Executive','CIO',41000,'ricardo.guerra@fiqueok.com.br','GRP_EXEC_TECH'),
    -> ('Laszlo','Bock','FP006','Executive','CHRO',38000,'laszlo.bock@fiqueok.com.br','GRP_HR_EXEC'),
cutive',    -> ('Donner','Marcos','FP007','Executive','CSO',43000,'donner.marcos@fiqueok.com.br','GRP_SEC_ADMINS'),
    -> ('Lucas','Carvalho','FP008','Technology - Dev','Senior Software Engineer',18000,'lucas.carvalho@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Juliana','Lima','FP009','Technology - Dev','Software Engineer',15000,'juliana.lima@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Gabriel','Martins','FP010','Technology - Dev','Junior Developer',9000,'gabriel.martins@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Patrícia','Silva','FP011','Technology - Dev','Backend Engineer',16500,'patricia.silva@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Felipe','Barbosa','FP012','Technology - Dev','Frontend Developer',14000,'felipe.barbosa@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Renata','Azevedo','FP013','Technology - Dev','Mobile Developer',15500,'renata.azevedo@fiqueok.com.br','GRP_IT_DEV'),
    -> ('André','Costa','FP014','Technology - Dev','Full Stack Developer',17500,'andre.costa@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Tatiane','Nunes','FP015','Technology - DevOps','DevOps Engineer',18000,'tatiane.nunes@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Eduardo','Ribeiro','FP016','Technology - DevOps','Cloud Engineer',17000,'eduardo.ribeiro@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Leonardo','Moreira','FP017','Technology - DevOps','Site Reliability Engineer',19000,'leonardo.moreira@fiqueok.com.br','GRP_IT_DEVOPS'),
18','Te    -> ('Aline','Teixeira','FP018','Technology - DevOps','Automation Specialist',16000,'aline.teixeira@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Diego','Pinto','FP019','Technology - Security','Security Engineer',18500,'diego.pinto@fiqueok.com.br','GRP_SEC_ENGINEERS'),
    -> ('Marcos','Gonçalves','FP020','Technology - Security','IAM Specialist',19500,'marcos.goncalves@fiqueok.com.br','GRP_SEC_IAM'),
    -> ('Beatriz','Ramos','FP021','Technology - Security','Information Security Analyst',13000,'beatriz.ramos@fiqueok.com.br','GRP_SEC_ANALYSTS'),
    -> ('Jonathan','Lopes','FP022','Technology - Security','Security Architect',22000,'jonathan.lopes@fiqueok.com.br','GRP_SEC_ADMINS'),
    -> ('Viviane','Machado','FP023','Technology - Data','Data Engineer',17500,'viviane.machado@fiqueok.com.br','GRP_DATA_ENGINEERS'),
    -> ('Gustavo','Castro','FP024','Technology - Data','Data Analyst',12000,'gustavo.castro@fiqueok.com.br','GRP_DATA_ANALYSTS'),
    -> ('Larissa','Campos','FP025','Technology - Data','Data Scientist',19000,'larissa.campos@fiqueok.com.br','GRP_DATA_SCIENCE'),
s','FP    -> ('Ricardo','Moraes','FP026','Technology - Data','BI Developer',14000,'ricardo.moraes@fiqueok.com.br','GRP_DATA_BI'),
    -> ('Jéssica','Cardoso','FP027','Technology - Data','ETL Specialist',15500,'jessica.cardoso@fiqueok.com.br','GRP_DATA_ETL'),
    -> ('Carlos','Rezende','FP028','Operations','Settlement Officer',9500,'carlos.rezende@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Amanda','Freitas','FP029','Operations','Settlement Analyst',8500,'amanda.freitas@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Thiago','Pereira','FP030','Operations','Chargeback Analyst',10000,'thiago.pereira@fiqueok.com.br','GRP_OPS_CHARGEBACK'),
    -> ('Marcelo','Tavares','FP031','Operations','Settlement Coordinator',12000,'marcelo.tavares@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
,'FP03    -> ('Daniela','Rocha','FP032','Operations','Chargeback Coordinator',11500,'daniela.rocha@fiqueok.com.br','GRP_OPS_CHARGEBACK'),
    -> ('Rogério','Neves','FP033','Operations','Payment Operations Analyst',9000,'rogerio.neves@fiqueok.com.br','GRP_OPS_PAYMENT'),
    -> ('Vanessa','Dias','FP034','Operations','Reconciliation Specialist',10500,'vanessa.dias@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Murilo','Barros','FP035','Operations','Settlement Assistant',7500,'murilo.barros@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Daniel','Coelho','FP036','Operations','Chargeback Specialist',9500,'daniel.coelho@fiqueok.com.br','GRP_OPS_CHARGEBACK'),
    -> ('Helena','Ferreira','FP037','Operations','Payment Execution Lead',13000,'helena.ferreira@fiqueok.com.br','GRP_OPS_PAYMENT'),
rla','A    -> ('Carla','Araújo','FP038','Fraud & Compliance','Fraud Analyst',10000,'carla.araujo@fiqueok.com.br','GRP_FRAUD_ANALYST'),
,'FP03    -> ('Rodrigo','Monteiro','FP039','Fraud & Compliance','Senior Fraud Investigator',14000,'rodrigo.monteiro@fiqueok.com.br','GRP_FRAUD_INVEST'),
,'FP04    -> ('Priscila','Duarte','FP040','Fraud & Compliance','Compliance Analyst',12000,'priscila.duarte@fiqueok.com.br','GRP_COMPLIANCE'),
    -> ('Sérgio','Amaral','FP041','Fraud & Compliance','KYC Specialist',11000,'sergio.amaral@fiqueok.com.br','GRP_COMPLIANCE_KYC'),
    -> ('Letícia','Marques','FP042','Fraud & Compliance','AML Officer',13500,'leticia.marques@fiqueok.com.br','GRP_COMPLIANCE_AML'),
'    -> João'('João','Meireles','FP043','Fraud & Compliance','Fraud Detection Specialist',12500,'joao.meireles@fiqueok.com.br','GRP_FRAUD_DETECT'),
ívia','S    -> ('Lívia','Sales','FP044','Fraud & Compliance','Fraud Operations Analyst',9000,'livia.sales@fiqueok.com.br','GRP_FRAUD_ANALYST'),
    -> ('Henrique','Falcão','FP045','Fraud & Compliance','Risk and Control Officer',15500,'henrique.falcao@fiqueok.com.br','GRP_RISK_CONTROLS'),
    -> ('Débora','Menezes','FP046','Fraud & Compliance','Compliance Coordinator',13000,'debora.menezes@fiqueok.com.br','GRP_COMPLIANCE'),
    -> ('Rafaela','Viana','FP047','Fraud & Compliance','Cyber Risk Analyst',15000,'rafaela.viana@fiqueok.com.br','GRP_SEC_ANALYSTS'),
    -> ('Pedro','Queiroz','FP048','Commercial & CS','Customer Success Lead',12000,'pedro.queiroz@fiqueok.com.br','GRP_COMM_CS'),
    -> ('Ana','Paula','FP049','Commercial & CS','Customer Success Analyst',8500,'ana.paula@fiqueok.com.br','GRP_COMM_CS'),
50','Co    -> ('Carlos','Eduardo','FP050','Commercial & CS','Inside Sales Executive',11500,'carlos.eduardo@fiqueok.com.br','GRP_COMM_SALES'),
    -> ('Gabriela','Cruz','FP051','Commercial & CS','Sales Development Rep',9500,'gabriela.cruz@fiqueok.com.br','GRP_COMM_SALES'),
    -> ('Luciana','Ferraz','FP052','Commercial & CS','Account Manager',12500,'luciana.ferraz@fiqueok.com.br','GRP_COMM_ACCOUNTS'),
    -> ('Renato','Silveira','FP053','Commercial & CS','Pre-Sales Engineer',15000,'renato.silveira@fiqueok.com.br','GRP_COMM_SALES'),
    -> ('Paulo','Henrique','FP054','Commercial & CS','Marketing Analyst',8500,'paulo.henrique@fiqueok.com.br','GRP_COMM_MARKETING'),
    -> ('Michele','Carneiro','FP055','Commercial & CS','Retention Specialist',9500,'michele.carneiro@fiqueok.com.br','GRP_COMM_CS'),
    -> ('Tatiana','Castilho','FP056','Commercial & CS','Communication Coordinator',11000,'tatiana.castilho@fiqueok.com.br','GRP_COMM_MARKETING'),
    -> ('Vinícius','Fonseca','FP057','Commercial & CS','Sales Manager',16500,'vinicius.fonseca@fiqueok.com.br','GRP_COMM_MANAGERS'),
    -> ('Sabrina','Mota','FP058','HR & Finance','HR Analyst',9000,'sabrina.mota@fiqueok.com.br','GRP_HR'),
    -> atália'('Natália','Lacerda','FP059','HR & Finance','Finance Analyst',9500,'natalia.lacerda@fiqueok.com.br','GRP_FINANCE'),
0','HR    -> ('Anderson','Peixoto','FP060','HR & Finance','Payroll Specialist',8500,'anderson.peixoto@fiqueok.com.br','GRP_HR_PAYROLL'),
    -> ('Caroline','Mendes','FP061','HR & Finance','Accounting Coordinator',12000,'caroline.mendes@fiqueok.com.br','GRP_FINANCE'),
    -> ('Joana','Batista','FP062','HR & Finance','People Business Partner',13000,'joana.batista@fiqueok.com.br','GRP_HR_PBP'),
    -> ('Samuel','Rocha','FP063','Technology - Dev','Front-End Developer',12500,'samuel.rocha@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Roberta','Vidal','FP064','Technology - Dev','Backend Developer',14000,'roberta.vidal@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Igor','Américo','FP065','Technology - DevOps','Cloud Administrator',17000,'igor.americo@fiqueok.com.br','GRP_IT_DEVOPS'),
'Danil    -> ('Danilo','Assis','FP066','Technology - Security','Security Analyst',13000,'danilo.assis@fiqueok.com.br','GRP_SEC_ANALYSTS'),
    -> ('Fábio','Correia','FP067','Technology - Data','DataOps Engineer',16000,'fabio.correia@fiqueok.com.br','GRP_DATA_ENGINEERS'),
    -> ('Karla','Vasconcelos','FP068','Operations','Settlement Associate',8500,'karla.vasconcelos@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Eduarda','Brandão','FP069','Fraud & Compliance','Fraud Prevention Analyst',9500,'eduarda.brandao@fiqueok.com.br','GRP_FRAUD_ANALYST'),
    -> ('Cássio','Borges','FP070','Commercial & CS','Account Executive',14500,'cassio.borges@fiqueok.com.br','GRP_COMM_SALES'),
    -> ('Patrícia','Macedo','FP071','HR & Finance','Recruiter',9500,'patricia.macedo@fiqueok.com.br','GRP_HR'),
    -> ('Felipe','Lourenço','FP072','Technology - Dev','Software Engineer',13500,'felipe.lourenco@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Amanda','Prado','FP073','Technology - DevOps','DevOps Specialist',17500,'amanda.prado@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Gustavo','Franco','FP074','Technology - Security','Penetration Tester',19500,'gustavo.franco@fiqueok.com.br','GRP_SEC_ADMINS'),
    -> ('Carla','Ribeiro','FP075','Technology - Data','Machine Learning Engineer',20000,'carla.ribeiro@fiqueok.com.br','GRP_DATA_SCIENCE'),
    -> ('Leandro','Rezende','FP076','Operations','Chargeback Analyst',9500,'leandro.rezende@fiqueok.com.br','GRP_OPS_CHARGEBACK'),
    -> ('Sofia','Bueno','FP077','Fraud & Compliance','Compliance Auditor',11500,'sofia.bueno@fiqueok.com.br','GRP_COMPLIANCE'),
mmercial    -> ('Arthur','Henrique','FP078','Commercial & CS','Customer Experience Designer',13000,'arthur.henrique@fiqueok.com.br','GRP_COMM_CS'),
    -> ('Beatriz','Moreira','FP079','HR & Finance','Compensation Analyst',10500,'beatriz.moreira@fiqueok.com.br','GRP_HR'),
    -> ('Lucas','Toscano','FP080','Technology - Dev','Software Architect',20000,'lucas.toscano@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Emanuel','Nogueira','FP081','Technology - DevOps','Infrastructure Engineer',16000,'emanuel.nogueira@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Cristina','Alvarenga','FP082','Technology - Security','Security Compliance Lead',21000,'cristina.alvarenga@fiqueok.com.br','GRP_SEC_ADMINS'),
    -> ('Raul','Andrade','FP083','Technology - Data','BI Analyst',11000,'raul.andrade@fiqueok.com.br','GRP_DATA_ANALYSTS'),
    -> ('Mariana','Quevedo','FP084','Operations','Operations Analyst',9500,'mariana.quevedo@fiqueok.com.br','GRP_OPS_PAYMENT'),
    -> ('Thiago','Pazinato','FP085','Fraud & Compliance','Risk Data Analyst',12500,'thiago.pazinato@fiqueok.com.br','GRP_RISK_CONTROLS'),
    -> ('Andreia','Abreu','FP086','Commercial & CS','Sales Operations Analyst',12000,'andreia.abreu@fiqueok.com.br','GRP_COMM_SALES'),
    -> ('Murilo','Vasques','FP087','HR & Finance','Financial Controller',16000,'murilo.vasques@fiqueok.com.br','GRP_FINANCE'),
','Tech    -> ('Helena','Santiago','FP088','Technology - Dev','QA Engineer',11500,'helena.santiago@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Julio','Oliveira','FP089','Technology - DevOps','Release Manager',15500,'julio.oliveira@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Tatiana','Pozzebon','FP090','Technology - Security','SOC Analyst',12500,'tatiana.pozzebon@fiqueok.com.br','GRP_SEC_ANALYSTS'),
echnolo    -> ('Rodrigo','Mendes','FP091','Technology - Data','Data Governance Specialist',16500,'rodrigo.mendes@fiqueok.com.br','GRP_DATA_GOV'),
    -> ('Camila','Freire','FP092','Operations','Settlement Officer',10000,'camila.freire@fiqueok.com.br','GRP_OPS_SETTLEMENT'),
    -> ('Paula','Bernardes','FP093','Fraud & Compliance','Compliance Assistant',8500,'paula.bernardes@fiqueok.com.br','GRP_COMPLIANCE'),
    -> ('Marcos','Teixeira','FP094','Commercial & CS','Channel Partner Manager',15500,'marcos.teixeira@fiqueok.com.br','GRP_COMM_MANAGERS'),
    -> ('Rafaela','Costa','FP095','HR & Finance','HR Coordinator',11000,'rawfaela.costa@fiqueok.com.br','GRP_HR'),
    -> ('Guilherme','Lira','FP096','Technology - Dev','Backend Developer',14000,'guilherme.lira@fiqueok.com.br','GRP_IT_DEV'),
    -> ('Elaine','Cardin','FP097','Technology - DevOps','Cloud Architect',22000,'elaine.cardin@fiqueok.com.br','GRP_IT_DEVOPS'),
    -> ('Ricardo','Ferraz','FP098','Technology - Data','Analytics Engineer',17500,'ricardo.ferraz@fiqueok.com.br','GRP_DATA_ENGINEERS'),
    -> ('Tainá','Lopes','FP099','Operations','Chargeback Assistant',8000,'taina.lopes@fiqueok.com.br','GRP_OPS_CHARGEBACK'),
00','Fr    -> ('Fernanda','Rossetti','FP100','Fraud & Compliance','Laundering Prevention Specialist',14000,'fernanda.rossetti@fiqueok.com.br','GRP_COMPLIANCE_AML');
Query OK, 100 rows affected (0.008 sec)
Records: 100  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]> SELECT count(*) FROM staging_employees;
+----------+
| count(*) |
+----------+
|      100 |
+----------+
1 row in set (0.000 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> CREATE TABLE secgroup_role_map (
    ->     SecurityGroup   VARCHAR(100) PRIMARY KEY,
    ->     user_role_id    INT NOT NULL
    -> );
opulando com os IDs padrão do OrangeHRM (1=Admin, 2=ESS, etc.)
-- Ajuste estes IDs amanhã se necessário após validar na UI do Orange
INSERT INTO secgroup_role_map (SecurityGroup, user_role_id) VALUES
('GRP_EXEC_BOARD', 1),
('GRP_SEC_ADMINS', 1),
('GRP_IT_DEQuery OK, 0 rows affected (0.010 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Populando com os IDs padrão do OrangeHRM (1=Admin, 2=ESS, etc.)
MariaDB [greenfield_hr]> -- Ajuste estes IDs amanhã se necessário após validar na UI do Orange
MariaDB [greenfield_hr]> INSERT INTO secgroup_role_map (SecurityGroup, user_role_id) VALUES
    -> ('GRP_EXEC_BOARD', 1),
    -> ('GRP_SEC_ADMINS', 1),
    -> ('GRP_IT_DEV', 2),
    -> ('GRP_HR', 2);
Query OK, 4 rows affected (0.001 sec)
Records: 4  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO hs_hr_employee (employee_id, emp_firstname, emp_lastname, work_email, job_title_code, work_station)
    -> SELECT
    ->     s.EmployeeID,
    ->     s.FirstName,
    ->     s.LastName,
    ->     s.Email,
    ->     j.id AS job_title_code,
    ->     u.id AS work_station
    -> FROM staging_employees s
    -> JOIN ohrm_job_title j ON j.job_title = s.JobTitle
bunit u     -> JOIN ohrm_subunit u ON u.name = s.Department;
ERROR 1146 (42S02): Table 'greenfield_hr.hs_hr_employee' doesn't exist
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| greenfield_hr      |
| information_schema |
| mysql              |
| orangehrm          |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.000 sec)

MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_employee (employee_id, emp_firstname, emp_lastname, emp_work_email, job_title_code, work_station)
    -> SELECT
    ->     s.EmployeeID,
    ->     s.FirstName,
    ->     s.LastName,
    ->     s.Email,
    ->     j.id AS job_title_code,
    ->     u.id AS work_station
oyees s
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.ohrm_job_title j ON j.job_title_name = s.JobTitle
    -> JOIN orangehrm.ohrm_subunit u ON u.name = s.Department;
ERROR 1054 (42S22): Unknown column 'j.job_title_name' in 'ON'
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> DESC orangehrm.ohrm_job_title;
+-----------------+--------------+------+-----+---------+----------------+
| Field           | Type         | Null | Key | Default | Extra          |
+-----------------+--------------+------+-----+---------+----------------+
| id              | int(13)      | NO   | PRI | NULL    | auto_increment |
| job_title       | varchar(100) | NO   |     | NULL    |                |
| job_description | varchar(400) | YES  |     | NULL    |                |
| note            | varchar(400) | YES  |     | NULL    |                |
| is_deleted      | tinyint(1)   | YES  |     | 0       |                |
+-----------------+--------------+------+-----+---------+----------------+
5 rows in set (0.001 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_employee (employee_id, emp_firstname, emp_lastname, emp_work_email, job_title_code, work_station)
    -> SELECT
    ->     s.EmployeeID,
    ->     s.FirstName,
    ->     s.LastName,
    ->     s.Email,
    ->     j.id AS job_title_code,
    ->     u.id AS work_station
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.ohrm_job_title j ON j.job_title = s.JobTitle
    -> JOIN orangehrm.ohrm_subunit u ON u.name = s.Department;
Query OK, 0 rows affected (0.001 sec)
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_emp_basicsalary (emp_number, currency_id, ebsal_basic_salary, payperiod_code, salary_component)
    -> SELECT
    ->     e.emp_number,
    ->     'BRL',
HAR)    ->     CAST(s.Salary AS CHAR),
    ->     'MONTHLY',
    ->     'Base Salary'
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID;
Query OK, 0 rows affected (0.001 sec)
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> SELECT DISTINCT s.JobTitle as No_CSV, j.job_title as No_Sistema
    -> FROM greenfield_hr.staging_employees s
    -> LEFT JOIN orangehrm.ohrm_job_title j ON j.job_title = s.JobTitle
    -> WHERE j.id IS NULL;
+----------------------------------+------------+
| No_CSV                           | No_Sistema |
+----------------------------------+------------+
| CEO                              | NULL       |
| Chairman                         | NULL       |
| COO                              | NULL       |
| CTO                              | NULL       |
| CIO                              | NULL       |
| CHRO                             | NULL       |
| CSO                              | NULL       |
| Senior Software Engineer         | NULL       |
| Software Engineer                | NULL       |
| Junior Developer                 | NULL       |
| Backend Engineer                 | NULL       |
| Frontend Developer               | NULL       |
| Mobile Developer                 | NULL       |
| Full Stack Developer             | NULL       |
| DevOps Engineer                  | NULL       |
| Cloud Engineer                   | NULL       |
| Site Reliability Engineer        | NULL       |
| Automation Specialist            | NULL       |
| Security Engineer                | NULL       |
| IAM Specialist                   | NULL       |
| Information Security Analyst     | NULL       |
| Security Architect               | NULL       |
| Data Engineer                    | NULL       |
| Data Analyst                     | NULL       |
| Data Scientist                   | NULL       |
| BI Developer                     | NULL       |
| ETL Specialist                   | NULL       |
| Settlement Officer               | NULL       |
| Settlement Analyst               | NULL       |
| Chargeback Analyst               | NULL       |
| Settlement Coordinator           | NULL       |
| Chargeback Coordinator           | NULL       |
| Payment Operations Analyst       | NULL       |
| Reconciliation Specialist        | NULL       |
| Settlement Assistant             | NULL       |
| Chargeback Specialist            | NULL       |
| Payment Execution Lead           | NULL       |
| Fraud Analyst                    | NULL       |
| Senior Fraud Investigator        | NULL       |
| Compliance Analyst               | NULL       |
| KYC Specialist                   | NULL       |
| AML Officer                      | NULL       |
| Fraud Detection Specialist       | NULL       |
| Fraud Operations Analyst         | NULL       |
| Risk and Control Officer         | NULL       |
| Compliance Coordinator           | NULL       |
| Cyber Risk Analyst               | NULL       |
| Customer Success Lead            | NULL       |
| Customer Success Analyst         | NULL       |
| Inside Sales Executive           | NULL       |
| Sales Development Rep            | NULL       |
| Account Manager                  | NULL       |
| Pre-Sales Engineer               | NULL       |
| Marketing Analyst                | NULL       |
| Retention Specialist             | NULL       |
| Communication Coordinator        | NULL       |
| Sales Manager                    | NULL       |
| HR Analyst                       | NULL       |
| Finance Analyst                  | NULL       |
| Payroll Specialist               | NULL       |
| Accounting Coordinator           | NULL       |
| People Business Partner          | NULL       |
| Front-End Developer              | NULL       |
| Backend Developer                | NULL       |
| Cloud Administrator              | NULL       |
| Security Analyst                 | NULL       |
| DataOps Engineer                 | NULL       |
| Settlement Associate             | NULL       |
| Fraud Prevention Analyst         | NULL       |
| Account Executive                | NULL       |
| Recruiter                        | NULL       |
| DevOps Specialist                | NULL       |
| Penetration Tester               | NULL       |
| Machine Learning Engineer        | NULL       |
| Compliance Auditor               | NULL       |
| Customer Experience Designer     | NULL       |
| Compensation Analyst             | NULL       |
| Software Architect               | NULL       |
| Infrastructure Engineer          | NULL       |
| Security Compliance Lead         | NULL       |
| BI Analyst                       | NULL       |
| Operations Analyst               | NULL       |
| Risk Data Analyst                | NULL       |
| Sales Operations Analyst         | NULL       |
| Financial Controller             | NULL       |
| QA Engineer                      | NULL       |
| Release Manager                  | NULL       |
| SOC Analyst                      | NULL       |
| Data Governance Specialist       | NULL       |
| Compliance Assistant             | NULL       |
| Channel Partner Manager          | NULL       |
| HR Coordinator                   | NULL       |
| Cloud Architect                  | NULL       |
| Analytics Engineer               | NULL       |
| Chargeback Assistant             | NULL       |
| Laundering Prevention Specialist | NULL       |
+----------------------------------+------------+
96 rows in set (0.000 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.ohrm_job_title (job_title)
    -> SELECT DISTINCT JobTitle
    -> FROM greenfield_hr.staging_employees
    -> WHERE JobTitle NOT IN (SELECT job_title FROM orangehrm.ohrm_job_title);
Query OK, 96 rows affected (0.007 sec)
Records: 96  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.ohrm_subunit (name, unit_id)
    -> SELECT DISTINCT Department, 1 -- 1 é geralmente o ID da estrutura raiz
    -> FROM greenfield_hr.staging_employees
    -> WHERE Department NOT IN (SELECT name FROM orangehrm.ohrm_subunit);
Query OK, 0 rows affected (0.000 sec)
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_employee (employee_id, emp_firstname, emp_lastname, emp_work_email, job_title_code, work_station)
    -> SELECT
    ->     TRIM(s.EmployeeID),
    ->     TRIM(s.FirstName),
    ->     TRIM(s.LastName),
    ->     TRIM(s.Email),
    ->     j.id,
    ->     u.id
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.ohrm_job_title j ON j.job_title = s.JobTitle
    -> JOIN orangehrm.ohrm_subunit u ON u.name = s.Department;
Query OK, 100 rows affected (0.021 sec)
Records: 100  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_emp_basicsalary (emp_number, currency_id, ebsal_basic_salary, payperiod_code, salary_component)
    -> SELECT
    ->     e.emp_number,
    ->     'BRL',
    ->     CAST(s.Salary AS CHAR),
    ->     'MONTHLY',
    ->     'Base Salary'
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID;
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`orangehrm`.`hs_hr_emp_basicsalary`, CONSTRAINT `hs_hr_emp_basicsalary_ibfk_4` FOREIGN KEY (`payperiod_code`) REFERENCES `hs_hr_payperiod` (`payperiod_code`) ON DELETE CASCADE)
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT INTO orangehrm.ohrm_user (user_name, user_role_id, emp_number, status, deleted)
    -> SELECT
    ->     s.Email,
    ->     m.user_role_id,
umber,     ->
    e.emp_number,
    ->     1, -- 1 = Ativo
    ->     0  -- 0 = Não deletado
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID
    -> JOIN greenfield_hr.secgroup_role_map m ON m.SecurityGroup = s.SecurityGroup;
Query OK, 22 rows affected (0.006 sec)
Records: 22  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Inserir o período de pagamento necessário
MariaDB [greenfield_hr]> INSERT IGNORE INTO orangehrm.hs_hr_payperiod (payperiod_code, payperiod_name)
    -> VALUES ('MONTHLY', 'Monthly');
ários noQuery OK, 1 row affected (0.004 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Tentar a inserção dos salários novamente
MariaDB [greenfield_hr]> INSERT INTO orangehrm.hs_hr_emp_basicsalary (emp_number, currency_id, ebsal_basic_salary, payperiod_code, salary_component)
    -> SELECT
    ->     e.emp_number,
s.Salar    ->     'BRL',
    ->     CAST(s.Salary AS CHAR),
    ->     'MONTHLY',
    ->     'Base Salary'
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID;
Query OK, 100 rows affected (0.007 sec)
Records: 100  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Inserir mapeamentos para os grupos que faltaram (Exemplos)
MariaDB [greenfield_hr]> INSERT IGNORE INTO greenfield_hr.secgroup_role_map (SecurityGroup, user_role_id) VALUES
    -> ('GRP_IT_DEVOPS', 2),
    -> ('GRP_SEC_IAM', 2),
    -> ('GRP_SEC_ENGINEERS', 2),
    -> ('GRP_DATA_ENGINEERS', 2),
,
('G    -> ('GRP_OPS_SETTLEMENT', 2),
    -> ('GRP_FRAUD_ANALYST', 2),
    -> ('GRP_COMM_CS', 2),
    -> ('GRP_FINANCE', 2);
pita para outros grupos conforme necessário.

-- Rodar a criação de usuários novamente (apenas para quem aindaQuery OK, 8 rows affected (0.004 sec)
Records: 8  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]> -- Repita para outros grupos conforme necessário.
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Rodar a criação de usuários novamente (apenas para quem ainda não tem)
MariaDB [greenfield_hr]> INSERT INTO orangehrm.ohrm_user (user_name, user_role_id, emp_number, status, deleted)
    -> SELECT
    ->     s.Email, m.user_role_id, e.emp_number, 1, 0
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID
cgroup_    -> JOIN greenfield_hr.secgroup_role_map m ON m.SecurityGroup = s.SecurityGroup
    -> WHERE s.Email NOT IN (SELECT user_name FROM orangehrm.ohrm_user);
Query OK, 31 rows affected (0.008 sec)
Records: 31  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> INSERT IGNORE INTO greenfield_hr.secgroup_role_map (SecurityGroup, user_role_id) VALUES
    -> ('GRP_EXEC_FINANCE', 1), ('GRP_EXEC_OPERATIONS', 1), ('GRP_EXEC_TECH', 1), ('GRP_HR_EXEC', 1),
    -> ('GRP_SEC_ANALYSTS', 2), ('GRP_IT_DEVOPS', 2), ('GRP_DATA_ANALYSTS', 2), ('GRP_DATA_SCIENCE', 2),
    -> ('GRP_DATA_BI', 2), ('GRP_DATA_ETL', 2), ('GRP_OPS_CHARGEBACK', 2), ('GRP_OPS_PAYMENT', 2),
    -> ('GRP_FRAUD_INVEST', 2), ('GRP_COMPLIANCE', 2), ('GRP_COMPLIANCE_KYC', 2), ('GRP_COMPLIANCE_AML', 2),
    -> ('GRP_FRAUD_DETECT', 2), ('GRP_RISK_CONTROLS', 2), ('GRP_COMM_SALES', 2), ('GRP_COMM_ACCOUNTS', 2),
    -> ('GRP_COMM_MARKETING', 2), ('GRP_COMM_MANAGERS', 2), ('GRP_HR', 2), ('GRP_HR_PAYROLL', 2),
R_PB    -> ('GRP_HR_PBP', 2), ('GRP_DATA_GOV', 2), ('GRP_COMPLIANCE_AML', 2);
e novamente a carga de usuários para completar os 100
INSERT INTO orangehrm.ohrm_user (user_name, user_role_id, emp_number, status, deleted)
SELECT
    Query OK, 24 rows affected, 3 warnings (0.005 sec)
Records: 27  Duplicates: 3  Warnings: 3

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> -- Execute novamente a carga de usuários para completar os 100
MariaDB [greenfield_hr]> INSERT INTO orangehrm.ohrm_user (user_name, user_role_id, emp_number, status, deleted)
    -> SELECT
    ->     s.Email, m.user_role_id, e.emp_number, 1, 0
    -> FROM greenfield_hr.staging_employees s
    -> JOIN orangehrm.hs_hr_employee e ON e.employee_id = s.EmployeeID
    -> JOIN greenfield_hr.secgroup_role_map m ON m.SecurityGroup = s.SecurityGroup
    -> WHERE s.Email NOT IN (SELECT user_name FROM orangehrm.ohrm_user);
Query OK, 47 rows affected (0.008 sec)
Records: 47  Duplicates: 0  Warnings: 0

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> SELECT count(*) FROM orangehrm.ohrm_user;
+----------+
| count(*) |
+----------+
|      102 |
+----------+
1 row in set (0.000 sec)

MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> DROP TABLE greenfield_hr.staging_employees;
nha a secgroup_role_map se quiser mostrar o mapeamentoQuery OK, 0 rows affected (0.008 sec)

MariaDB [greenfield_hr]> -- Mantenha a secgroup_role_map se quiser mostrar o mapeamento técnico.
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]>
MariaDB [greenfield_hr]> SELECT

    jt    ->     e.employee_id,
    ->     e.emp_firstname,
    ->     jt.job_title,
    ->     s.ebsal_basic_salary AS Salary,
    ->     u.user_name AS Login_Status
    -> FROM orangehrm.hs_hr_employee e
    -> LEFT JOIN orangehrm.hs_hr_emp_basicsalary s ON e.emp_number = s.emp_number
    -> LEFT JOIN orangehrm.ohrm_job_title jt ON e.job_title_code = jt.id
    -> LEFT JOIN orangehrm.ohrm_user u ON e.emp_number = u.emp_number
    -> WHERE e.employee_id LIKE 'FP%'
    -> LIMIT 5;
+-------------+---------------+-----------+----------+--------------------------------+
| employee_id | emp_firstname | job_title | Salary   | Login_Status                   |
+-------------+---------------+-----------+----------+--------------------------------+
| FP001       | David         | CEO       | 48000.00 | david.velez@fiqueok.com.br     |
| FP002       | André         | Chairman  | 42000.00 | andre.chaves@fiqueok.com.br    |
| FP003       | Luisa         | COO       | 39000.00 | luisa.sotero@fiqueok.com.br    |
| FP004       | Daniela       | CTO       | 44000.00 | daniela.binatti@fiqueok.com.br |
| FP005       | Ricardo       | CIO       | 41000.00 | ricardo.guerra@fiqueok.com.br  |
+-------------+---------------+-----------+----------+--------------------------------+
5 rows in set (0.001 sec)

MariaDB [greenfield_hr]>
