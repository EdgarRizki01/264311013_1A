
--SELECT
SELECT p.nama_pelanggan,
       COUNT(j.id_penjualan) AS jumlah_transaksi,
       SUM(j.jumlah * j.harga_satuan_aktual - j.diskon_item) AS total_penjualan
FROM PENJUALAN j

--JOIN
JOIN PELANGGAN p ON j.id_pelanggan = p.id_pelanggan

--WHERE
WHERE j.tanggal_penjualan BETWEEN '2026-01-01' AND '2026-12-31'

--GROUP BY
GROUP BY p.id_pelanggan, p.nama_pelanggan
ORDER BY total_penjualan DESC;