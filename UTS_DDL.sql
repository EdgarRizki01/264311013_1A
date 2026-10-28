-- =====================================================================
-- 1. PENGGUNA
-- =====================================================================
CREATE TABLE PENGGUNA (
    id_pengguna              VARCHAR(10)   NOT NULL,
    nama                     VARCHAR(100)  NOT NULL,
    tanggal_lahir            DATE          NULL,
    email                    VARCHAR(100)  NOT NULL,
    status_aktif             TINYINT(1)    NOT NULL DEFAULT 1,
    alamat                   TEXT          NULL,
    nomor_telepon            VARCHAR(20)   NULL,
    role                     VARCHAR(20)   NOT NULL DEFAULT 'Kasir',
    jumlah_transaksi_dibuat  INT           NOT NULL DEFAULT 0,
    CONSTRAINT pk_pengguna PRIMARY KEY (id_pengguna),
    CONSTRAINT uq_pengguna_email UNIQUE (email),
    CONSTRAINT chk_pengguna_status CHECK (status_aktif IN (0, 1)),
    CONSTRAINT chk_pengguna_role CHECK (role IN ('Pemilik', 'Admin', 'Kasir')),
    CONSTRAINT chk_pengguna_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT chk_pengguna_jml CHECK (jumlah_transaksi_dibuat >= 0)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. PELANGGAN
-- =====================================================================
CREATE TABLE PELANGGAN (
    id_pelanggan    VARCHAR(10)   NOT NULL,
    nama_pelanggan  VARCHAR(100)  NOT NULL,
    kontak          VARCHAR(20)   NULL,
    CONSTRAINT pk_pelanggan PRIMARY KEY (id_pelanggan)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. PEMASOK
-- =====================================================================
CREATE TABLE PEMASOK (
    id_pemasok    VARCHAR(10)   NOT NULL,
    nama_pemasok  VARCHAR(100)  NOT NULL,
    kontak        VARCHAR(20)   NULL,
    email         VARCHAR(100)  NULL,
    CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok),
    CONSTRAINT chk_pemasok_email CHECK (email IS NULL OR email LIKE '%_@_%._%')
) ENGINE=InnoDB;

-- =====================================================================
-- 4. PRODUK
-- =====================================================================
CREATE TABLE PRODUK (
    id_produk          VARCHAR(10)    NOT NULL,
    nama_produk        VARCHAR(100)   NOT NULL,
    harga_satuan_baku  DECIMAL(15,2)  NOT NULL DEFAULT 0,
    CONSTRAINT pk_produk PRIMARY KEY (id_produk),
    CONSTRAINT chk_produk_harga CHECK (harga_satuan_baku >= 0)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. KAS_REKENING
-- =====================================================================
CREATE TABLE KAS_REKENING (
    id_kas         VARCHAR(10)    NOT NULL,
    nama_kas       VARCHAR(100)   NOT NULL,
    jenis_kas      VARCHAR(20)    NOT NULL,
    saldo_terkini  DECIMAL(15,2)  NOT NULL DEFAULT 0,
    CONSTRAINT pk_kas PRIMARY KEY (id_kas),
    CONSTRAINT chk_kas_jenis CHECK (jenis_kas IN ('Tunai', 'Bank', 'E-Wallet'))
) ENGINE=InnoDB;

-- =====================================================================
-- 6. TRANSAKSI
-- =====================================================================
CREATE TABLE TRANSAKSI (
    id_transaksi       VARCHAR(15)    NOT NULL,
    tanggal_transaksi  DATE           NOT NULL,
    waktu_transaksi    TIME           NOT NULL,
    keterangan         VARCHAR(255)   NULL,
    status_validasi    VARCHAR(15)    NOT NULL DEFAULT 'Belum Valid',
    id_pengguna        VARCHAR(10)    NOT NULL,
    id_pelanggan       VARCHAR(10)    NULL,
    id_pemasok         VARCHAR(10)    NULL,
    total_nilai        DECIMAL(15,2)  NOT NULL DEFAULT 0,
    jenis_transaksi    VARCHAR(15)    NOT NULL,
    CONSTRAINT pk_transaksi PRIMARY KEY (id_transaksi),
    CONSTRAINT fk_transaksi_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES PENGGUNA (id_pengguna)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transaksi_pelanggan FOREIGN KEY (id_pelanggan)
        REFERENCES PELANGGAN (id_pelanggan)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transaksi_pemasok FOREIGN KEY (id_pemasok)
        REFERENCES PEMASOK (id_pemasok)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_transaksi_jenis
        CHECK (jenis_transaksi IN ('Penjualan', 'Pembelian', 'Kas Pemilik')),
    CONSTRAINT chk_transaksi_status
        CHECK (status_validasi IN ('Belum Valid', 'Valid', 'Ditolak')),
    CONSTRAINT chk_transaksi_total CHECK (total_nilai >= 0),
    CONSTRAINT chk_transaksi_pihak CHECK (
        (jenis_transaksi = 'Penjualan'   AND id_pelanggan IS NOT NULL AND id_pemasok IS NULL) OR
        (jenis_transaksi = 'Pembelian'   AND id_pemasok   IS NOT NULL AND id_pelanggan IS NULL) OR
        (jenis_transaksi = 'Kas Pemilik' AND id_pelanggan IS NULL     AND id_pemasok IS NULL)
    )
) ENGINE=InnoDB;

CREATE INDEX idx_transaksi_tanggal ON TRANSAKSI (tanggal_transaksi);
CREATE INDEX idx_transaksi_jenis   ON TRANSAKSI (jenis_transaksi);

-- =====================================================================
-- 7. BUKTI_TRANSAKSI
-- =====================================================================
CREATE TABLE BUKTI_TRANSAKSI (
    id_bukti         VARCHAR(15)   NOT NULL,
    id_transaksi     VARCHAR(15)   NOT NULL,
    nomor_bukti      VARCHAR(30)   NOT NULL,
    tanggal_bukti    DATE          NOT NULL,
    jenis_transaksi  VARCHAR(15)   NOT NULL,
    keterangan       VARCHAR(255)  NULL,
    berkas_bukti     VARCHAR(255)  NULL,
    id_pelanggan     VARCHAR(10)   NULL,
    id_pemasok       VARCHAR(10)   NULL,
    id_pengguna      VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_bukti PRIMARY KEY (id_bukti),
    CONSTRAINT uq_bukti_nomor UNIQUE (nomor_bukti),
    CONSTRAINT fk_bukti_transaksi FOREIGN KEY (id_transaksi)
        REFERENCES TRANSAKSI (id_transaksi)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bukti_pelanggan FOREIGN KEY (id_pelanggan)
        REFERENCES PELANGGAN (id_pelanggan)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bukti_pemasok FOREIGN KEY (id_pemasok)
        REFERENCES PEMASOK (id_pemasok)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bukti_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES PENGGUNA (id_pengguna)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_bukti_jenis
        CHECK (jenis_transaksi IN ('Penjualan', 'Pembelian', 'Kas Pemilik'))
) ENGINE=InnoDB;

-- =====================================================================
-- 8. PEMBAYARAN  (mendukung pembayaran bertahap)
-- =====================================================================
CREATE TABLE PEMBAYARAN (
    id_pembayaran      VARCHAR(15)    NOT NULL,
    id_transaksi       VARCHAR(15)    NOT NULL,
    tanggal_pembayaran DATE           NOT NULL,
    arah_pembayaran    VARCHAR(10)    NOT NULL,
    metode_bayar       VARCHAR(20)    NOT NULL,
    jumlah_bayar       DECIMAL(15,2)  NOT NULL,
    id_kas             VARCHAR(10)    NOT NULL,
    referensi          VARCHAR(100)   NULL,
    CONSTRAINT pk_pembayaran PRIMARY KEY (id_pembayaran),
    CONSTRAINT fk_pembayaran_transaksi FOREIGN KEY (id_transaksi)
        REFERENCES TRANSAKSI (id_transaksi)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pembayaran_kas FOREIGN KEY (id_kas)
        REFERENCES KAS_REKENING (id_kas)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pembayaran_arah CHECK (arah_pembayaran IN ('Masuk', 'Keluar')),
    CONSTRAINT chk_pembayaran_metode
        CHECK (metode_bayar IN ('Tunai', 'Transfer', 'QRIS', 'Lainnya')),
    CONSTRAINT chk_pembayaran_jumlah CHECK (jumlah_bayar > 0)
) ENGINE=InnoDB;

CREATE INDEX idx_pembayaran_transaksi ON PEMBAYARAN (id_transaksi);

-- =====================================================================
-- 9. TRANSAKSI_KAS_PEMILIK  (relasi 1 : 0..1 dengan TRANSAKSI)
-- =====================================================================
CREATE TABLE TRANSAKSI_KAS_PEMILIK (
    id_transaksi        VARCHAR(15)    NOT NULL,
    jenis_kas_pemilik   VARCHAR(20)    NOT NULL,
    jumlah              DECIMAL(15,2)  NOT NULL,
    keterangan_tambahan VARCHAR(255)   NULL,
    CONSTRAINT pk_kas_pemilik PRIMARY KEY (id_transaksi),
    CONSTRAINT fk_kas_pemilik_transaksi FOREIGN KEY (id_transaksi)
        REFERENCES TRANSAKSI (id_transaksi)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_kas_pemilik_jenis
        CHECK (jenis_kas_pemilik IN ('Setoran Modal', 'Prive')),
    CONSTRAINT chk_kas_pemilik_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

-- =====================================================================
-- 10. DETAIL_PENJUALAN
-- =====================================================================
CREATE TABLE DETAIL_PENJUALAN (
    id_transaksi         VARCHAR(15)    NOT NULL,
    no_item              INT            NOT NULL,
    id_produk            VARCHAR(10)    NOT NULL,
    jumlah               INT            NOT NULL,
    harga_satuan_actual  DECIMAL(15,2)  NOT NULL,
    diskon_item          DECIMAL(15,2)  NOT NULL DEFAULT 0,
    subtotal             DECIMAL(15,2)  NOT NULL,
    CONSTRAINT pk_detail_penjualan PRIMARY KEY (id_transaksi, no_item),
    CONSTRAINT fk_dpenjualan_transaksi FOREIGN KEY (id_transaksi)
        REFERENCES TRANSAKSI (id_transaksi)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dpenjualan_produk FOREIGN KEY (id_produk)
        REFERENCES PRODUK (id_produk)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dpenjualan_noitem   CHECK (no_item > 0),
    CONSTRAINT chk_dpenjualan_jumlah   CHECK (jumlah > 0),
    CONSTRAINT chk_dpenjualan_harga    CHECK (harga_satuan_actual >= 0),
    CONSTRAINT chk_dpenjualan_diskon   CHECK (diskon_item >= 0
                                              AND diskon_item <= jumlah * harga_satuan_actual),
    CONSTRAINT chk_dpenjualan_subtotal
        CHECK (subtotal = jumlah * harga_satuan_actual - diskon_item)
) ENGINE=InnoDB;

-- =====================================================================
-- 11. DETAIL_PEMBELIAN
-- =====================================================================
CREATE TABLE DETAIL_PEMBELIAN (
    id_transaksi         VARCHAR(15)    NOT NULL,
    no_item              INT            NOT NULL,
    id_produk            VARCHAR(10)    NOT NULL,
    jumlah               INT            NOT NULL,
    harga_satuan_actual  DECIMAL(15,2)  NOT NULL,
    diskon_item          DECIMAL(15,2)  NOT NULL DEFAULT 0,
    subtotal             DECIMAL(15,2)  NOT NULL,
    CONSTRAINT pk_detail_pembelian PRIMARY KEY (id_transaksi, no_item),
    CONSTRAINT fk_dpembelian_transaksi FOREIGN KEY (id_transaksi)
        REFERENCES TRANSAKSI (id_transaksi)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dpembelian_produk FOREIGN KEY (id_produk)
        REFERENCES PRODUK (id_produk)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dpembelian_noitem   CHECK (no_item > 0),
    CONSTRAINT chk_dpembelian_jumlah   CHECK (jumlah > 0),
    CONSTRAINT chk_dpembelian_harga    CHECK (harga_satuan_actual >= 0),
    CONSTRAINT chk_dpembelian_diskon   CHECK (diskon_item >= 0
                                              AND diskon_item <= jumlah * harga_satuan_actual),
    CONSTRAINT chk_dpembelian_subtotal
        CHECK (subtotal = jumlah * harga_satuan_actual - diskon_item)
) ENGINE=InnoDB;

-- =====================================================================
-- 12. LAPORAN_KEUANGAN
-- =====================================================================
CREATE TABLE LAPORAN_KEUANGAN (
    id_laporan     VARCHAR(15)   NOT NULL,
    judul_laporan  VARCHAR(150)  NOT NULL,
    periode        VARCHAR(30)   NOT NULL,
    tanggal_cetak  DATE          NOT NULL,
    id_pengguna    VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_laporan PRIMARY KEY (id_laporan),
    CONSTRAINT fk_laporan_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES PENGGUNA (id_pengguna)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- VIEW: pemantauan sisa tagihan (proses bisnis pembayaran bertahap)
-- sisa_tagihan = total_nilai - total pembayaran
-- status: Lunas / Belum Lunas / Lebih Bayar
-- =====================================================================
CREATE VIEW v_sisa_tagihan AS
SELECT
    t.id_transaksi,
    t.jenis_transaksi,
    t.total_nilai,
    COALESCE(SUM(p.jumlah_bayar), 0)                   AS total_dibayar,
    t.total_nilai - COALESCE(SUM(p.jumlah_bayar), 0)   AS sisa_tagihan,
    CASE
        WHEN COALESCE(SUM(p.jumlah_bayar), 0) = t.total_nilai THEN 'Lunas'
        WHEN COALESCE(SUM(p.jumlah_bayar), 0) > t.total_nilai THEN 'Lebih Bayar'
        ELSE 'Belum Lunas'
    END                                                AS status_tagihan
FROM TRANSAKSI t
LEFT JOIN PEMBAYARAN p ON p.id_transaksi = t.id_transaksi
WHERE t.jenis_transaksi IN ('Penjualan', 'Pembelian')
GROUP BY t.id_transaksi, t.jenis_transaksi, t.total_nilai;
