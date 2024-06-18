CREATE TABLE log_operacoes_restaurante (
    log_id SERIAL PRIMARY KEY,
    operacao_data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedimento_nome VARCHAR(255) NOT NULL
);

CREATE OR REPLACE PROCEDURE sp_obter_notas_para_o_troco(
    OUT resultado_troco VARCHAR(500),
    IN valor_troco INT
) LANGUAGE plpgsql AS $$
DECLARE
    notas_200 INT := 0;
    notas_100 INT := 0;
    notas_50 INT := 0;
    notas_20 INT := 0;
    notas_10 INT := 0;
    notas_5 INT := 0;
    notas_2 INT := 0;
    moedas_1 INT := 0;
BEGIN
    notas_200 := valor_troco / 200;
    notas_100 := (valor_troco % 200) / 100;
    notas_50 := (valor_troco % 200 % 100) / 50;
    notas_20 := (valor_troco % 200 % 100 % 50) / 20;
    notas_10 := (valor_troco % 200 % 100 % 50 % 20) / 10;
    notas_5 := (valor_troco % 200 % 100 % 50 % 20 % 10) / 5;
    notas_2 := (valor_troco % 200 % 100 % 50 % 20 % 10 % 5) / 2;
    moedas_1 := (valor_troco % 200 % 100 % 50 % 20 % 10 % 5 % 2) / 1;

    -- Registrar no log
    INSERT INTO log_operacoes_restaurante (procedimento_nome) VALUES ('sp_obter_notas_para_o_troco');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calcular_valor_do_troco(
    OUT troco INT,
    IN valor_cliente INT,
    IN valor_total INT
) LANGUAGE plpgsql AS $$
BEGIN
    troco := valor_cliente - valor_total;

    -- Registrar no log
    INSERT INTO log_operacoes_restaurante (procedimento_nome) VALUES ('sp_calcular_valor_do_troco');
END;
$$;
