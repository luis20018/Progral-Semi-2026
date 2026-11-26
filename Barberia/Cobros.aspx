<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) Cargar();
}
private void Cargar() {
Factura.DataSource=Tabla("SELECT f.Id,CONCAT(f.Id,' - ',cl.Nombre) AS Texto FROM Facturas f JOIN Citas c ON c.Id=f.Cita JOIN Clientes cl ON cl.Id=c.Cliente WHERE ISNULL((SELECT SUM(Monto) FROM Pagos WHERE Factura=f.Id),0)<ISNULL((SELECT SUM(Cantidad*PrecioUnitario) FROM DetalleFactura WHERE Factura=f.Id),0)");
Factura.DataTextField="Texto";
Factura.DataValueField="Id";
Factura.DataBind();
Metodo.DataSource=Tabla("SELECT Id,Nombre AS Texto FROM MetodosPago");
Metodo.DataTextField="Texto";
Metodo.DataValueField="Id";
Metodo.DataBind();
lista.DataSource=Tabla("SELECT p.Id,f.Id AS Factura,cl.Nombre AS Cliente,m.Nombre AS Metodo,p.Monto,p.Fecha FROM Pagos p JOIN Facturas f ON f.Id=p.Factura JOIN Citas c ON c.Id=f.Cita JOIN Clientes cl ON cl.Id=c.Cliente JOIN MetodosPago m ON m.Id=p.Metodo");
lista.DataBind();
}
protected void Guardar(object s, EventArgs e) {
try {
GuardarOperacion("DECLARE @total decimal(10,2)=(SELECT SUM(Cantidad*PrecioUnitario) FROM DetalleFactura WHERE Factura=@Factura); DECLARE @pagado decimal(10,2)=ISNULL((SELECT SUM(Monto) FROM Pagos WHERE Factura=@Factura),0); IF @total IS NULL OR @Monto<=0 OR @Monto>@total-@pagado THROW 50001,'Monto inválido',1; INSERT INTO Pagos(Factura,Metodo,Monto,Fecha) VALUES(@Factura,@Metodo,@Monto,@Fecha);",P("@Factura",Convert.ToInt32(Factura.SelectedValue)),P("@Metodo",Convert.ToInt32(Metodo.SelectedValue)),P("@Monto",decimal.Parse(Monto.Text)),P("@Fecha",DateTime.Parse(Fecha.Text)));
Cargar();
mensaje.Text="Registro guardado";
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1>Registro de pagos</h1><div class="panel"><label>Factura</label><asp:DropDownList ID="Factura" runat="server"/><label>Metodo</label><asp:DropDownList ID="Metodo" runat="server"/><label>Monto</label><asp:TextBox ID="Monto" runat="server" TextMode="SingleLine"/><label>Fecha</label><asp:TextBox ID="Fecha" runat="server" TextMode="Date"/><asp:Button runat="server" Text="Guardar" OnClick="Guardar"/><asp:Label ID="mensaje" runat="server"/></div><div class="panel"><input type="search" placeholder="Buscar" oninput="filtrar(this.value)"/><asp:GridView ID="lista" runat="server" EmptyDataText="Sin registros"/></div><script>function filtrar(v){document.querySelectorAll("table tr").forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(v.toLowerCase())?"":"none"})}</script></asp:Content>