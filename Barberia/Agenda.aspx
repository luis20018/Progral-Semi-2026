<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) Cargar();
}
private void Cargar() {
Cliente.DataSource=Tabla("SELECT Id,Nombre + N' ' + Apellido AS Texto FROM Clientes WHERE Activo=1");
Cliente.DataTextField="Texto";
Cliente.DataValueField="Id";
Cliente.DataBind();
Cliente.Items.Insert(0,new ListItem("Seleccione cliente",""));
Empleado.DataSource=Tabla("SELECT e.Id,e.Nombre + N' ' + e.Apellido + N' | ' + u.Usuario AS Texto FROM Empleados e JOIN UsuarioEmpleado ue ON ue.EmpleadoId=e.Id JOIN Usuarios u ON u.Id=ue.UsuarioId WHERE e.Activo=1 AND u.Activo=1 AND u.Rol='Barbero'");
Empleado.DataTextField="Texto";
Empleado.DataValueField="Id";
Empleado.DataBind();
Empleado.Items.Insert(0,new ListItem("Seleccione barbero",""));
Servicio.DataSource=Tabla("SELECT Id,Nombre AS Texto FROM Servicios WHERE Activo=1");
Servicio.DataTextField="Texto";
Servicio.DataValueField="Id";
Servicio.DataBind();
Servicio.Items.Insert(0,new ListItem("Seleccione servicio",""));
lista.DataSource=Tabla("SELECT c.Id,cl.Nombre AS Cliente,e.Nombre AS Empleado,s.Nombre AS Servicio,c.Fecha,c.Hora,c.Estado FROM Citas c JOIN Clientes cl ON cl.Id=c.Cliente JOIN Empleados e ON e.Id=c.Empleado JOIN DetalleCita d ON d.Cita=c.Id JOIN Servicios s ON s.Id=d.Servicio");
lista.DataBind();
citaCorregir.DataSource=Tabla("SELECT c.Id,CONVERT(nvarchar(20),c.Id)+N' | '+CONVERT(nvarchar(10),c.Fecha,103)+N' '+CONVERT(nvarchar(8),c.Hora)+N' | '+cl.Nombre+N' | '+e.Nombre+N' | Cuenta: '+COALESCE(u.Usuario,N'Sin cuenta') AS Texto FROM Citas c JOIN Clientes cl ON cl.Id=c.Cliente JOIN Empleados e ON e.Id=c.Empleado LEFT JOIN UsuarioEmpleado ue ON ue.EmpleadoId=e.Id LEFT JOIN Usuarios u ON u.Id=ue.UsuarioId ORDER BY c.Fecha,c.Hora");
citaCorregir.DataTextField="Texto";
citaCorregir.DataValueField="Id";
citaCorregir.DataBind();
cuentaDestino.DataSource=Tabla("SELECT e.Id,u.Usuario+N' | '+e.Nombre+N' '+e.Apellido AS Texto FROM Usuarios u JOIN UsuarioEmpleado ue ON ue.UsuarioId=u.Id JOIN Empleados e ON e.Id=ue.EmpleadoId WHERE u.Rol='Barbero' AND u.Activo=1 AND e.Activo=1");
cuentaDestino.DataTextField="Texto";
cuentaDestino.DataValueField="Id";
cuentaDestino.DataBind();
}
protected void CorregirAsignacion(object s, EventArgs e) {
try {
if (!EsDueno()) throw new Exception("Acceso no autorizado.");
if (citaCorregir.SelectedValue=="" || cuentaDestino.SelectedValue=="") throw new Exception("Seleccione la cita y la cuenta del barbero.");
GuardarOperacion("UPDATE Citas SET Empleado=@e WHERE Id=@c AND EXISTS(SELECT 1 FROM UsuarioEmpleado ue JOIN Usuarios u ON u.Id=ue.UsuarioId JOIN Empleados em ON em.Id=ue.EmpleadoId WHERE ue.EmpleadoId=@e AND u.Rol='Barbero' AND u.Activo=1 AND em.Activo=1); IF @@ROWCOUNT=0 THROW 50001,N'No se pudo asignar la cita.',1;",P("@e",Convert.ToInt32(cuentaDestino.SelectedValue)),P("@c",Convert.ToInt32(citaCorregir.SelectedValue)));
Cargar();
avisoAsignacion.Text="Cita asignada correctamente.";
} catch (Exception ex) {
avisoAsignacion.Text=Server.HtmlEncode(ex.Message);
}
}
protected void Guardar(object s, EventArgs e) {
try {
if (Cliente.SelectedValue=="" || Empleado.SelectedValue=="" || Servicio.SelectedValue=="") throw new Exception("Seleccione cliente, barbero y servicio.");
GuardarOperacion("IF EXISTS(SELECT 1 FROM Citas WHERE Empleado=@Empleado AND Fecha=@Fecha AND Hora=@Hora AND Estado<>'Cancelada') THROW 50001,'Horario ocupado',1; INSERT INTO Citas(Cliente,Empleado,Fecha,Hora,Estado,Observaciones) VALUES(@Cliente,@Empleado,@Fecha,@Hora,'Confirmada',''); INSERT INTO DetalleCita(Cita,Servicio,Cantidad,PrecioUnitario) SELECT SCOPE_IDENTITY(),Id,1,Precio FROM Servicios WHERE Id=@Servicio;",P("@Cliente",Convert.ToInt32(Cliente.SelectedValue)),P("@Empleado",Convert.ToInt32(Empleado.SelectedValue)),P("@Servicio",Convert.ToInt32(Servicio.SelectedValue)),P("@Fecha",DateTime.Parse(Fecha.Text)),P("@Hora",TimeSpan.Parse(Hora.Text)));
Cargar();
mensaje.Text="Registro guardado";
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1>Agenda de citas</h1><div class="panel"><p>Si falta un cliente o barbero, regístralo primero.</p><p><a href="Gestion.aspx?t=Clientes">+ Registrar cliente</a> | <a href="Gestion.aspx?t=Empleados">+ Registrar empleado</a></p><label>Cliente</label><asp:DropDownList ID="Cliente" runat="server"/><label>Barbero</label><asp:DropDownList ID="Empleado" runat="server"/><label>Servicio</label><asp:DropDownList ID="Servicio" runat="server"/><label>Fecha</label><asp:TextBox ID="Fecha" runat="server" TextMode="Date"/><label>Hora</label><asp:TextBox ID="Hora" runat="server" TextMode="Time"/><asp:Button runat="server" Text="Guardar" OnClick="Guardar"/><asp:Label ID="mensaje" runat="server"/></div><div class="panel"><input type="search" placeholder="Buscar" oninput="filtrar(this.value)"/><asp:GridView ID="lista" runat="server" EmptyDataText="Sin registros"/></div><div class="panel"><h2>Corregir asignación de cita</h2><p>Seleccione una cita existente y la cuenta del barbero que debe atenderla.</p><label>Cita</label><asp:DropDownList ID="citaCorregir" runat="server"/><label>Cuenta del barbero</label><asp:DropDownList ID="cuentaDestino" runat="server"/><asp:Button runat="server" Text="Asignar cita" OnClick="CorregirAsignacion" OnClientClick="return confirm('¿Asignar esta cita al barbero seleccionado?');"/><asp:Label ID="avisoAsignacion" runat="server"/></div><script>function filtrar(v){document.querySelectorAll("table tr").forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(v.toLowerCase())?"":"none"})}</script></asp:Content>