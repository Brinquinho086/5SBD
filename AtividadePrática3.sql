1. "Usando a sintaxe proprietária da Oracle, exiba o nome de cada cliente junto com o número de sua conta."
{
SELECT cliente_nome, conta_numero
FROM cliente, conta 
WHERE cliente_cod = cliente_cliente_cod;
}

2. "Mostre todas as combinações possíveis de clientes e agências (produto cartesiano)."
{
SELECT c.cliente_nome, a.agencia_nome
FROM cliente c, agencia a;
}

3. "Usando aliases de tabela, exiba o nome dos clientes e a cidade da agência onde mantêm conta."
{
SELECT c.cliente_nome, a.agencia_cidade
FROM cliente c, conta ct, agencia a
WHERE c.cliente_cod = ct.cliente_cliente_cod AND ct.agencia_agencia_cod = a.agencia_cod;
}

4. "Exiba o saldo total de todas as contas cadastradas."
{
SELECT SUM(saldo) AS Saldo_Total
FROM conta;
}

5. "Mostre o maior saldo e a média de saldo entre todas as contas."
{
SELECT MAX(saldo) AS Maior_Saldo, AVG(saldo) AS Media_Saldo
FROM conta;
}

6. "Apresente a quantidade total de contas cadastradas."
{
SELECT COUNT(*) AS Quantidade_de_Contas
FROM conta;
}

7. "Liste o número de cidades distintas onde os clientes residem."
{
SELECT COUNT(DISTINCT cidade) AS Cidades_Distintas
FROM cliente;
}

8. "Exiba o número da conta e o saldo, substituindo valores nulos por zero."
{
SELECT conta_numero, NVL(saldo, 0) AS Saldo
FROM conta;
}

9. "Exiba a média de saldo por cidade dos clientes."
{
SELECT c.cidade, AVG(ct.saldo) AS Media_Saldo_Cidade
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY c.cidade;
}

10. "Liste apenas as cidades com mais de 3 contas associadas a seus moradores."
{
SELECT c.cidade
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY c.cidade
HAVING COUNT(ct.conta_numero) > 3;
}

11. "Utilize a cláusula ROLLUP para exibir o total de saldos por cidade da agência e o total geral."
{
SELECT a.agencia_cidade, SUM(ct.saldo) AS Total_Saldos
FROM agencia a
JOIN conta ct ON a.agencia_cod = ct.agencia_agencia_cod
GROUP BY ROLLUP(a.agencia_cidade);
}

12. "Faça uma consulta com UNION que combine os nomes de cidades dos clientes e das agências, sem repetições."
{
SELECT cidade FROM cliente
UNION
SELECT agencia_cidade FROM agencia;
}

------------------------------------------------------------------------------------------------------------

1. "Liste os nomes dos clientes cujas contas possuem saldo acima da média geral de todas as contas registradas."
{
SELECT DISTINCT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo > (SELECT AVG(saldo) FROM conta);
}

2. "Exiba os nomes dos clientes cujos saldos são iguais ao maior saldo encontrado no banco."
{
SELECT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo = (SELECT MAX(saldo) FROM conta);
}

3. "Liste as cidades onde a quantidade de clientes é maior que a quantidade média de clientes por cidade."
{
SELECT cidade
FROM cliente
GROUP BY cidade
HAVING COUNT(cliente_cod) > (SELECT AVG(COUNT(cliente_cod)) FROM cliente GROUP BY cidade);
}

4. "Liste os nomes dos clientes com saldo igual a qualquer um dos dez maiores saldos registrados."
{
SELECT DISTINCT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo IN (
    SELECT saldo FROM conta ORDER BY saldo DESC FETCH FIRST 10 ROWS ONLY
);
}

5. "Liste os clientes que possuem saldo menor que todos os saldos dos clientes da cidade de Niterói."
{
SELECT DISTINCT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo < ALL (
    SELECT s.saldo
    FROM conta s
    JOIN cliente cli ON s.cliente_cliente_cod = cli.cliente_cod
    WHERE cli.cidade = 'Niterói'
);
}

6. "Liste os clientes cujos saldos estão entre os saldos de clientes de Volta Redonda."
{
SELECT DISTINCT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo BETWEEN
    (SELECT MIN(s.saldo) FROM conta s JOIN cliente cli ON s.cliente_cliente_cod = cli.cliente_cod WHERE cli.cidade = 'Volta Redonda')
AND
    (SELECT MAX(s.saldo) FROM conta s JOIN cliente cli ON s.cliente_cliente_cod = cli.cliente_cod WHERE cli.cidade = 'Volta Redonda');
}

7. "Exiba os nomes dos clientes cujos saldos são maiores que a média de saldo das contas da mesma agência."
{
SELECT DISTINCT c.cliente_nome
FROM cliente c
JOIN conta ct_outer ON c.cliente_cod = ct_outer.cliente_cliente_cod
WHERE ct_outer.saldo > (
    SELECT AVG(ct_inner.saldo)
    FROM conta ct_inner
    WHERE ct_inner.agencia_agencia_cod = ct_outer.agencia_agencia_cod
);
}

8. "Liste os nomes e cidades dos clientes que têm saldo inferior à média de sua própria cidade."
{
SELECT c_outer.cliente_nome, c_outer.cidade
FROM cliente c_outer
JOIN conta ct_outer ON c_outer.cliente_cod = ct_outer.cliente_cliente_cod
WHERE ct_outer.saldo < (
    SELECT AVG(ct_inner.saldo)
    FROM cliente c_inner
    JOIN conta ct_inner ON c_inner.cliente_cod = ct_inner.cliente_cliente_cod
    WHERE c_inner.cidade = c_outer.cidade
);
}

9. "Liste os nomes dos clientes que possuem pelo menos uma conta registrada no banco."
{
SELECT c.cliente_nome
FROM cliente c
WHERE EXISTS (
    SELECT 1
    FROM conta ct
    WHERE ct.cliente_cliente_cod = c.cliente_cod
);
}

10. "Liste os nomes dos clientes que ainda não possuem conta registrada no banco."
{
SELECT c.cliente_nome
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM conta ct
    WHERE ct.cliente_cliente_cod = c.cliente_cod
);
}

11. "Usando a cláusula WITH, calcule a média de saldo por cidade e exiba os clientes que possuem saldo acima da média de sua cidade."
{
WITH MediaPorCidade AS (
    SELECT c.cidade,  AVG(ct.saldo) AS media_saldo_da_cidade
    FROM cliente c
    JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
    GROUP BY c.cidade
)
SELECT c.cliente_nome
FROM  cliente c
JOIN  conta ct ON c.cliente_cod = ct.cliente_cliente_cod
JOIN   MediaPorCidade mpc ON c.cidade = mpc.cidade
WHERE  ct.saldo > mpc.media_saldo_da_cidade;
}
