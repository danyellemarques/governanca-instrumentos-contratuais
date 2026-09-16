-- =============================================
-- SISTEMA DE GOVERNANÇA DE INSTRUMENTOS
-- Dados de exemplo
-- =============================================
SET search_path TO governanca;

-- ORGANIZACOES
INSERT INTO organizacao (nome, cnpj, tipo, contato_nome, contato_email, contato_telefone) VALUES
('Prefeitura de Aracaju','13.128.780/0001-04','Prefeitura','Carlos Silva','carlos@aracaju.se.gov.br','(79) 3179-1000'),
('Prefeitura de Itabaiana','13.104.740/0001-50','Prefeitura','Maria Santos','maria@itabaiana.se.gov.br','(79) 3431-1000'),
('Instituto Educar','12.345.678/0001-90','ONG','Ana Oliveira','ana@institutoeducar.org.br','(79) 99999-1111'),
('Universidade Federal de Sergipe','13.031.547/0001-04','Universidade','Prof. Roberto Lima','roberto@ufs.br','(79) 3194-6600'),
('Tech Solutions SE Ltda','98.765.432/0001-10','Empresa','Fernando Costa','fernando@techsolutions.com.br','(79) 3211-5500');

-- RESPONSAVEIS
INSERT INTO responsavel (nome, cargo, setor, email) VALUES
('Danyelle Marques','Analista de Processos','DIPLAN','danyelle@seed.se.gov.br'),
('Lucas Almeida','Coordenador de Convenios','DIPLAN','lucas@seed.se.gov.br'),
('Patricia Souza','Diretora de Planejamento','DIPLAN','patricia@seed.se.gov.br'),
('Ricardo Mendes','Analista Juridico','ASJUR','ricardo@seed.se.gov.br'),
('Fernanda Lima','Analista Financeiro','DIFIN','fernanda@seed.se.gov.br');

-- INSTRUMENTOS
INSERT INTO instrumento (numero, tipo, objeto, organizacao_id, responsavel_id, data_celebracao, data_vigencia_inicio, data_vigencia_fim, valor_total, status) VALUES
('CONV-2026/001','Convenio','Construcao de 3 creches no municipio de Aracaju',1, 1, '2026-01-15','2026-02-01','2027-01-31', 1500000.00, 'Ativo'),
('CONV-2026/002','Convenio','Reforma de 5 escolas rurais em Itabaiana',2, 1, '2026-03-01','2026-03-15','2026-12-31', 800000.00, 'Ativo'),
('TC-2026/001','Termo de Cooperacao','Programa de formacao continuada de professores',4, 2, '2026-02-10','2026-03-01','2026-11-30', 250000.00, 'Ativo'),
('CT-2026/001','Contrato','Fornecimento de equipamentos de informatica',5, 2, '2026-04-01','2026-04-15','2026-10-15', 620000.00, 'Ativo'),
('CONV-2025/010','Convenio','Programa de alfabetizacao na idade certa',3, 1, '2025-06-01','2025-07-01','2026-06-30', 350000.00, 'Encerrado'),
('CONV-2026/003','Convenio','Transporte escolar zona rural de Lagarto',1, 2, NULL, '2026-08-01','2027-07-31', 900000.00, 'Em elaboracao');

-- MARCOS
INSERT INTO marco (instrumento_id, descricao, data_prevista, data_realizada, status, valor_parcela) VALUES
(1,'Projeto executivo aprovado','2026-03-01','2026-03-05','Concluido',NULL),
(1,'Fundacao da 1a creche concluida','2026-06-01','2026-06-15','Concluido',500000.00),
(1,'Fundacao da 2a creche concluida','2026-09-01',NULL,'Pendente',500000.00),
(1,'Entrega final das 3 creches','2027-01-15',NULL,'Pendente',500000.00),
(2,'Laudo tecnico das 5 escolas','2026-04-01','2026-04-10','Concluido',NULL),
(2,'Reforma da escola 1 concluida','2026-06-15','2026-07-01','Concluido',160000.00),
(2,'Reforma da escola 2 concluida','2026-08-01',NULL,'Atrasado',160000.00),
(3,'1o modulo de formacao aplicado','2026-05-01','2026-05-01','Concluido',83333.33),
(3,'2o modulo de formacao aplicado','2026-08-01',NULL,'Pendente',83333.33),
(4,'1a entrega de equipamentos (50%)','2026-06-15','2026-06-20','Concluido',310000.00),
(4,'2a entrega de equipamentos (50%)','2026-09-15',NULL,'Pendente',310000.00);

-- AUDITORIAS
INSERT INTO auditoria (instrumento_id, auditor_id, data_auditoria, tipo, resultado, parecer, checklist_score, checklist_total) VALUES
(1,1,'2026-01-20','Entrada','Conforme','Documentacao completa e em conformidade.',10,10),
(1,1,'2026-06-20','Periodica','Parcialmente Conforme','Atraso de 14 dias na 2a entrega. Demais OK.',8,10),
(2,1,'2026-03-10','Entrada','Conforme','Todos os documentos verificados.',10,10),
(2,4,'2026-07-15','Periodica','Nao Conforme','Escola 2 sem inicio de obra. Prazo vencido.',5,10),
(3,2,'2026-02-15','Entrada','Conforme','Termo de cooperacao em conformidade.',9,10),
(4,2,'2026-04-10','Entrada','Conforme','Contrato e documentacao fiscal OK.',10,10),
(5,1,'2026-06-25','Encerramento','Conforme','Prestacao de contas aprovada. Encerrado.',10,10);

-- CHECKLIST_ITEM (auditoria 1 e 4 como exemplo)
INSERT INTO checklist_item (auditoria_id, criterio, conforme, observacao) VALUES
(1,'Plano de trabalho apresentado',TRUE,NULL),
(1,'Cronograma fisico-financeiro anexo',TRUE,NULL),
(1,'CNPJ regular na Receita Federal',TRUE,NULL),
(1,'Certidao negativa de debitos',TRUE,NULL),
(1,'Parecer juridico favoravel',TRUE,NULL),
(4,'Plano de trabalho apresentado',TRUE,NULL),
(4,'Cronograma fisico-financeiro anexo',TRUE,NULL),
(4,'Relatorio de execucao parcial',FALSE,'Nao apresentado pela prefeitura'),
(4,'Fotos do andamento da obra',FALSE,'Escola 2 sem registro fotografico'),
(4,'Notas fiscais dos materiais',FALSE,'Pendente de envio');

-- TRAMITACOES
INSERT INTO tramitacao (instrumento_id, etapa_origem, etapa_destino, responsavel_id, data_entrada, data_saida, dias_na_etapa, observacao) VALUES
(1,'Recebimento','Analise Documental',1,'2026-01-10','2026-01-12',2,NULL),
(1,'Analise Documental','Parecer Juridico',4,'2026-01-12','2026-01-18',6,NULL),
(1,'Parecer Juridico','Analise Financeira',5,'2026-01-18','2026-01-20',2,NULL),
(1,'Analise Financeira','Assinatura',3,'2026-01-20','2026-01-25',5,NULL),
(6,'Recebimento','Analise Documental',1,'2026-07-01',NULL,NULL,'Em analise documental'),
(2,'Recebimento','Analise Documental',1,'2026-02-20','2026-02-21',1,NULL),
(2,'Analise Documental','Parecer Juridico',4,'2026-02-21','2026-02-28',7,'Parecer devolvido para ajustes'),
(2,'Parecer Juridico','Assinatura',3,'2026-02-28','2026-03-01',1,NULL);

-- ADITIVOS
INSERT INTO aditivo (instrumento_id, tipo_aditivo, justificativa, valor_aditivo, prazo_adicional_dias, data_assinatura, status) VALUES
(2,'Prazo','Atraso nas obras da escola 2 por chuvas',NULL, 90, '2026-07-20','Aprovado'),
(1,'Valor','Reajuste de materiais de construcao (INCC)',150000.00, NULL, '2026-06-01','Aprovado'),
(4,'Misto','Inclusao de tablets e extensao do prazo',80000.00, 30, '2026-08-01','Em analise');

-- DOCUMENTOS
INSERT INTO documento (instrumento_id, tipo_documento, nome_arquivo, uploaded_por) VALUES
(1,'Plano de Trabalho','PT_CONV2026001.pdf','Danyelle Marques'),
(1,'Parecer Juridico','PJ_CONV2026001.pdf','Ricardo Mendes'),
(1,'Cronograma Fisico-Financeiro','CFF_CONV2026001.xlsx','Fernanda Lima'),
(2,'Plano de Trabalho','PT_CONV2026002.pdf','Danyelle Marques'),
(2,'Laudo Tecnico','LAUDO_CONV2026002.pdf','Lucas Almeida'),
(4,'Contrato Assinado','CT2026001_assinado.pdf','Patricia Souza'),
(5,'Prestacao de Contas Final','PC_CONV2025010.pdf','Danyelle Marques');
