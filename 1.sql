
-- Tabel Induk 1
CREATE TABLE `pelanggan` (
  `id_pelanggan` int NOT NULL AUTO_INCREMENT,
  `nama_pelanggan` varchar(100) NOT NULL,
  `kontak` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_pelanggan`)
) ENGINE=InnoDB;

-- Tabel Induk 2
CREATE TABLE `produk` (
  `id_produk` int NOT NULL AUTO_INCREMENT,
  `nama_produk` varchar(100) NOT NULL,
  `harga_satuan_baku` decimal(15,2) NOT NULL,
  PRIMARY KEY (`id_produk`)
) ENGINE=InnoDB;

-- Tabel Transaksi (Anak)
CREATE TABLE `penjualan` (
  `id_penjualan` int NOT NULL AUTO_INCREMENT,
  `tanggal_penjualan` date NOT NULL,
  `jumlah` int NOT NULL,
  `harga_satuan_aktual` decimal(15,2) NOT NULL,
  `diskon_item` decimal(15,2) NOT NULL DEFAULT '0.00',
  `id_pelanggan` int DEFAULT NULL,
  `id_produk` int DEFAULT NULL,
  PRIMARY KEY (`id_penjualan`),
  KEY `penjualan_pelanggan_fk` (`id_pelanggan`),
  KEY `penjualan_produk_fk` (`id_produk`),
  CONSTRAINT `penjualan_pelanggan_fk` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`),
  CONSTRAINT `penjualan_produk_fk` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`)
) ENGINE=InnoDB;