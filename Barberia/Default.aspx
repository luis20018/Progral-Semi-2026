<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
string[] consultas = new string[] {"SELECT COUNT(*) FROM Citas WHERE Fecha=CAST(GETDATE() AS date)","SELECT COUNT(*) FROM Clientes","SELECT COUNT(*) FROM Servicios WHERE Activo=1","SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE MONTH(Fecha)=MONTH(GETDATE()) AND YEAR(Fecha)=YEAR(GETDATE())"};
string[] titulos = new string[] {"Citas de hoy","Clientes","Servicios","Ingresos del mes ($)"};
for(int i=0;i<=3;i++){
tarjetas.Text += "<div class='tarjeta'>" + titulos[i] + "<h2>" + Tabla(consultas[i]).Rows[0][0].ToString() + "</h2></div>";
}
agenda.DataSource=Tabla("SELECT TOP 10 c.Fecha,c.Hora,cl.Nombre AS Cliente,e.Nombre AS Empleado,c.Estado FROM Citas c JOIN Clientes cl ON cl.Id=c.Cliente JOIN Empleados e ON e.Id=c.Empleado WHERE c.Fecha>=CAST(GETDATE() AS date) ORDER BY c.Fecha,c.Hora");
agenda.DataBind();
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><section class="hero"><div class="eyebrow">TU NEGOCIO, EN ORDEN</div><h1>Panel principal</h1><p>Bienvenido a Barbería. Organiza tus citas y administra tu negocio.</p><a class="action" href="Agenda.aspx">Ver agenda →</a></section><div class="metrics"><asp:Literal ID="tarjetas" runat="server"/></div><div class="panel"><h2>Próximas citas</h2><asp:GridView ID="agenda" runat="server" EmptyDataText="No hay citas próximas"/></div></asp:Content>