SELECT per.id AS id_person,
       month|| '-01' AS month,
       SUM(amount) as sum_of_transactions
FROM test_mb.bi_assignment_transaction tr
  LEFT JOIN test_mb.bi_assignment_account acc ON tr.id_account = acc.id
  LEFT JOIN test_mb.bi_assignment_person AS per ON acc.id_person = per.id
  LEFT JOIN test_mb.dates_table dt ON dt.full_date = tr.transaction_date
WHERE per.id IN (345,1234)
AND   (transaction_date >= '2020-02-15' AND transaction_date <= '2020-06-06')
GROUP BY 1,
         2
ORDER BY id_person DESC,
         month ASC
