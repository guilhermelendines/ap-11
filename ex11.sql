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

CREATE OR REPLACE PROCEDURE sp_finalizar_pedido(
    IN valor_pago_cliente INT,
    IN codigo_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
    valor_total_pedido INT;
BEGIN
    CALL sp_calcular_valor_total_pedido(codigo_pedido, valor_total_pedido);
    IF valor_pago_cliente < valor_total_pedido THEN
        RAISE NOTICE 'R$% insuficiente para pagar a conta de R$%', 
        valor_pago_cliente, valor_total_pedido;
    ELSE
        UPDATE pedido p SET
        data_modificacao = CURRENT_TIMESTAMP,
        status = 'fechado'
        WHERE p.cod_pedido = codigo_pedido;
    END IF;

    -- Registrar no log
    INSERT INTO log_operacoes_restaurante (procedimento_nome) VALUES ('sp_finalizar_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calcular_valor_total_pedido(
    IN codigo_pedido INT,
    OUT total_valor INT
) LANGUAGE plpgsql AS $$
BEGIN 
    SELECT SUM(i.valor) INTO total_valor
    FROM pedido p
    INNER JOIN tp_item_pedido ip ON p.cod_pedido = ip.cod_pedido
    INNER JOIN tp_item i ON ip.cod_item = i.cod_item
    WHERE p.cod_pedido = codigo_pedido;

    -- Registrar no log
    INSERT INTO log_operacoes_restaurante (procedimento_nome) VALUES ('sp_calcular_valor_total_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_inserir_item_pedido(
    IN item_id INT,
    IN pedido_id INT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Inserindo novo item
    INSERT INTO tp_item_pedido(cod_item, cod_pedido) VALUES (item_id, pedido_id);
    -- Atualizando data de modificação
    UPDATE pedido p SET data_modificacao = CURRENT_TIMESTAMP
    WHERE p.cod_pedido = pedido_id;

    -- Registrar no log
    INSERT INTO log_operacoes_restaurante (procedimento_nome) VALUES ('sp_inserir_item_pedido');
END;
$$;
