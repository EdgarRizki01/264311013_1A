--create

INSERT INTO pelanggan (nama_pelanggan, kontak)
VALUES
('Edgar', '08123123123'),
('Ridho', '08123123124'),
('Ahmad', '08123123125');

INSERT INTO produk
(nama_produk, harga_satuan_baku)
VALUES
('Mie Sedap', 3000),
('Kecap Manis', 2000),
('Mie Rebus', 3000);

INSERT INTO penjualan
(tanggal_penjualan, jumlah, harga_satuan_aktual, diskon_item, id_pelanggan, id_produk)
VALUES
('2026-9-10', 5, 3000.00, 0.00, 1, 1),
('2026-10-6', 2, 2000.00, 0.00, 2, 2),
('2026-10-17', 3, 3000.00, 0.00, 3, 3);

--READ
SELECT * FROM penjualan;

--UPDATE

UPDATE penjualan
SET tanggal_penjualan='2026-9-11'
WHERE id_penjualan=1;

--DELETE
DELETE FROM penjualan
WHERE id_penjualan=3;