<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) Cargar();
}
private void Cargar() {
Cita.DataSource=Tabla("SELECT c.Id,CONCAT(c.Id,' - ',cl.Nombre) AS Texto FROM Citas c JOIN Clientes cl ON cl.Id=c.Cliente WHERE c.Estado='Realizada'");
Cita.DataTextField="Texto";
Cita.DataValueField="Id";
Cita.DataBind();
lista.DataSource=Tabla("SELECT f.Id,cl.Nombre AS Cliente,f.Fecha,SUM(d.Cantidad*d.PrecioUnitario) AS Total FROM Facturas f JOIN Citas c ON c.Id=f.Cita JOIN Clientes cl ON cl.Id=c.Cliente JOIN DetalleFactura d ON d.Factura=f.Id GROUP BY f.Id,cl.Nombre,f.Fecha");
lista.DataBind();
}
protected void Guardar(object s, EventArgs e) {
try {
GuardarOperacion("IF EXISTS(SELECT 1 FROM Facturas WHERE Cita=@Cita) THROW 50001,'Cita facturada',1; IF NOT EXISTS(SELECT 1 FROM DetalleCita WHERE Cita=@Cita) THROW 50001,'Cita sin servicios',1; INSERT INTO Facturas(Cita,Fecha) VALUES(@Cita,@Fecha); DECLARE @f int=SCOPE_IDENTITY(); INSERT INTO DetalleFactura(Factura,Servicio,Cantidad,PrecioUnitario) SELECT @f,Servicio,Cantidad,PrecioUnitario FROM DetalleCita WHERE Cita=@Cita;",P("@Cita",Convert.ToInt32(Cita.SelectedValue)),P("@Fecha",DateTime.Parse(Fecha.Text)));
Cargar();
mensaje.Text="Registro guardado";
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1>Facturación</h1><div class="panel"><label>Cita</label><asp:DropDownList ID="Cita" runat="server"/><label>Fecha</label><asp:TextBox ID="Fecha" runat="server" TextMode="Date"/><asp:Button runat="server" Text="Guardar" OnClick="Guardar"/><asp:Label ID="mensaje" runat="server"/></div><div class="panel"><input type="search" placeholder="Buscar" oninput="filtrar(this.value)"/><asp:GridView ID="lista" runat="server" EmptyDataText="Sin registros"/></div><script>function filtrar(v){document.querySelectorAll("table tr").forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(v.toLowerCase())?"":"none"})}</script></asp:Content>