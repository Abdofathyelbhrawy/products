-- إنشاء جدول المنتجات
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    barcode VARCHAR(100) UNIQUE,
    description TEXT,
    category VARCHAR(100),
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول الفواتير
CREATE TABLE IF NOT EXISTS invoices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول عناصر الفاتورة
CREATE TABLE IF NOT EXISTS invoice_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_product_id ON invoice_items(product_id);

-- إنشاء دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء triggers لتحديث updated_at
CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- إنشاء دالة لحساب المجموع الفرعي
CREATE OR REPLACE FUNCTION calculate_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    NEW.subtotal = NEW.quantity * (SELECT price FROM products WHERE id = NEW.product_id);
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء trigger لحساب المجموع الفرعي
CREATE TRIGGER calculate_invoice_item_subtotal
    BEFORE INSERT OR UPDATE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION calculate_subtotal();

-- إنشاء دالة لتحديث مجموع الفاتورة
CREATE OR REPLACE FUNCTION update_invoice_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE invoices 
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0) 
        FROM invoice_items 
        WHERE invoice_id = COALESCE(NEW.invoice_id, OLD.invoice_id)
    )
    WHERE id = COALESCE(NEW.invoice_id, OLD.invoice_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- إنشاء triggers لتحديث مجموع الفاتورة
CREATE TRIGGER update_invoice_total_on_insert
    AFTER INSERT ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_invoice_total();

CREATE TRIGGER update_invoice_total_on_update
    AFTER UPDATE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_invoice_total();

CREATE TRIGGER update_invoice_total_on_delete
    AFTER DELETE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_invoice_total();

-- إدراج بيانات تجريبية
INSERT INTO products (name, price, barcode, description, category, stock) VALUES
('كوكا كولا', 2.50, '1234567890123', 'مشروب غازي', 'مشروبات', 100),
('شيبس', 1.50, '1234567890124', 'رقائق البطاطس', 'وجبات خفيفة', 50),
('خبز', 0.75, '1234567890125', 'خبز أبيض', 'مخبوزات', 200),
('حليب', 3.00, '1234567890126', 'حليب طازج', 'ألبان', 30),
('جبن', 5.50, '1234567890127', 'جبن شيدر', 'ألبان', 25)
ON CONFLICT (barcode) DO NOTHING;

-- تفعيل Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسات الأمان
-- المنتجات: يمكن للجميع قراءتها، فقط المستخدمين المسجلين يمكنهم تعديلها
CREATE POLICY "Products are viewable by everyone" ON products
    FOR SELECT USING (true);

CREATE POLICY "Products are editable by authenticated users" ON products
    FOR ALL USING (auth.role() = 'authenticated');

-- الفواتير: يمكن للمستخدمين رؤية فواتيرهم فقط
CREATE POLICY "Users can view their own invoices" ON invoices
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own invoices" ON invoices
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own invoices" ON invoices
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invoices" ON invoices
    FOR DELETE USING (auth.uid() = user_id);

-- عناصر الفاتورة: يمكن للمستخدمين رؤية عناصر فواتيرهم فقط
CREATE POLICY "Users can view invoice items of their invoices" ON invoice_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create invoice items for their invoices" ON invoice_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update invoice items of their invoices" ON invoice_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete invoice items of their invoices" ON invoice_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.user_id = auth.uid()
        )
    );
