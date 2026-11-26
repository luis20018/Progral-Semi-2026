<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><%@ Import Namespace="System.Linq" %><%@ Import Namespace="System.Collections.Generic" %><%@ Import Namespace="System.Data" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) {
cliente.DataSource=Tabla("SELECT Id,Nombre FROM Clientes WHERE Activo=1");
cliente.DataTextField="Nombre";
cliente.DataValueField="Id";
cliente.DataBind();
}
}
protected void Recomendar(object s, EventArgs e) {
if (cliente.SelectedValue=="") return;
var datos = Tabla("SELECT c.Cliente,d.Servicio,SUM(d.Cantidad) AS Veces FROM Citas c JOIN DetalleCita d ON d.Cita=c.Id WHERE c.Estado='Realizada' GROUP BY c.Cliente,d.Servicio");
var historial = datos.AsEnumerable().Where(r => Convert.ToInt32(r["Cliente"])==Convert.ToInt32(cliente.SelectedValue)).ToDictionary(r => Convert.ToInt32(r["Servicio"]),r => Convert.ToDouble(r["Veces"]));
var puntos = new Dictionary<int,double>();
foreach (var grupo in datos.AsEnumerable().Where(r => Convert.ToInt32(r["Cliente"])!=Convert.ToInt32(cliente.SelectedValue)).GroupBy(r => Convert.ToInt32(r["Cliente"]))) {
var similitud = grupo.Sum(r => (historial.ContainsKey(Convert.ToInt32(r["Servicio"])) ? 1.0 : 0.0));
if (historial.Count==0) similitud=1;
foreach (var r in grupo) {
var id = Convert.ToInt32(r["Servicio"]);
if (historial.ContainsKey(id)) continue;
if (!puntos.ContainsKey(id)) puntos[id]=0;
puntos[id]+=similitud*Convert.ToDouble(r["Veces"]);
}
}
var salida = new DataTable();
salida.Columns.Add("Servicio");
salida.Columns.Add("Precio",typeof(decimal));
foreach (var par in puntos.Where(x => x.Value>0).OrderByDescending(x => x.Value).Take(5)) {
var servicio = Tabla("SELECT Nombre,Precio FROM Servicios WHERE Id=@id AND Activo=1",P("@id",par.Key));
if (servicio.Rows.Count>0) salida.Rows.Add(servicio.Rows[0]["Nombre"],servicio.Rows[0]["Precio"]);
}
sugerencias.DataSource=salida;
sugerencias.DataBind();
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1>Recomendaciones de servicios</h1><asp:DropDownList ID="cliente" runat="server"/><asp:Button runat="server" Text="Recomendar" OnClick="Recomendar"/><input type="search" placeholder="Buscar sugerencias" oninput="document.querySelectorAll('table tr').forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(this.value.toLowerCase())?'':'none'})"/><asp:GridView ID="sugerencias" runat="server" EmptyDataText="No hay suficiente historial para recomendar"/></asp:Content>