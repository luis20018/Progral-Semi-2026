<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><%@ Import Namespace="System.Data" %><%@ Import Namespace="System.Data.SqlClient" %><%@ Import Namespace="System.Collections.Generic" %><script runat="server">
string entidad = default(string);
string[] defs = default(string[]);
protected void Page_Init(object s, EventArgs e) {
entidad=Request.QueryString["t"];
if (entidad == null || !Campos.ContainsKey(entidad)) entidad="Clientes";
cuenta.Visible=(entidad=="Empleados");
defs=Campos[entidad].Split(',');
titulo.Text=(entidad=="Clientes" ? "Registrar cliente" : (entidad=="Empleados" ? "Registrar empleado" : entidad));
foreach (var def in defs) {
var a = def.Split(':'); var n = a[0]; var tipo = a[1];
var panel = new Panel { CssClass="campo"};
panel.Controls.Add(new Label { Text=n, AssociatedControlID="f" + n});
if (tipo.StartsWith("r") || tipo=="b" || n=="Estado" || n=="Dia" || n=="Rol" || (n=="Tipo" && entidad=="Movimientos")) {
var ddl = new DropDownList { ID="f" + n};
if (tipo=="b") {
ddl.Items.Add(new ListItem("Sí","1"));
ddl.Items.Add(new ListItem("No","0"));
} else if (!tipo.StartsWith("r")) {
foreach(var opcion in (n=="Estado"?"Pendiente,Confirmada,Realizada,Cancelada":n=="Dia"?"Lunes,Martes,Miércoles,Jueves,Viernes,Sábado,Domingo":n=="Rol"?"Administrador,Cliente,Barbero":"Entrada,Salida").Split(',')) ddl.Items.Add(opcion);
} else {
var referencia = tipo.Substring(1);
var texto = (referencia=="Citas" || referencia=="Facturas" ? "CONVERT(varchar,Id)" : "Nombre");
ddl.DataSource=Tabla("SELECT Id," + texto + " AS Texto FROM " + referencia + " ORDER BY Id");
ddl.DataTextField="Texto";
ddl.DataValueField="Id";
ddl.DataBind();
}
panel.Controls.Add(ddl);
} else {
var txt = new TextBox { ID="f" + n, MaxLength=200};
if (tipo=="d") txt.TextMode=TextBoxMode.Date;
if (tipo=="h") txt.TextMode=TextBoxMode.DateTimeLocal;
if (tipo=="t") txt.TextMode=TextBoxMode.Time;
if (n=="Clave") txt.TextMode=TextBoxMode.Password;
panel.Controls.Add(txt);
}
editor.Controls.Add(panel);
}
}
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) Cargar();
}
private Control Campo(string n) {
foreach (Control c in editor.Controls) {
var f = c.FindControl("f" + n);
if (f != null) return f;
}
return null;
}
private void Cargar() {
var cols = new List<string>() {"Id"};
foreach (var d in defs) {
var a = d.Split(':');
if (a[0]!="Clave") cols.Add("[" + a[0] + "]");
}
grilla.DataSource=Tabla("SELECT " + string.Join(",",cols) + " FROM " + entidad + " ORDER BY Id DESC");
grilla.DataBind();
}
protected void Seleccionar(object s, EventArgs e) {
var id = Convert.ToInt32(grilla.SelectedDataKey.Value);
var r = Tabla("SELECT * FROM " + entidad + " WHERE Id=@id",P("@id",id)).Rows[0];
elegido.Value=id.ToString();
cuenta.Visible=(entidad=="Empleados");
if (entidad=="Empleados") {
var acceso = Tabla("SELECT u.Usuario FROM Usuarios u INNER JOIN UsuarioEmpleado ue ON ue.UsuarioId=u.Id WHERE ue.EmpleadoId=@id",P("@id",id));
usuarioBarbero.Text=(acceso.Rows.Count>0 ? Convert.ToString(acceso.Rows[0]["Usuario"]) : "");
claveBarbero.Text="";
confirmarBarbero.Text="";
}
foreach (var d in defs) {
var a = d.Split(':'); var n = a[0]; var tipo = a[1]; var c = Campo(n);
if (c is DropDownList) {
var ddl = ((DropDownList)c);
ddl.SelectedValue=(tipo=="b" ? (Convert.ToBoolean(r[n]) ? "1" : "0") : r[n].ToString());
} else {
var txt = ((TextBox)c);
if (n=="Clave") {
txt.Text="";
} else if (tipo=="d") {
txt.Text=Convert.ToDateTime(r[n]).ToString("yyyy-MM-dd");
} else if (tipo=="h") {
txt.Text=Convert.ToDateTime(r[n]).ToString("yyyy-MM-ddTHH:mm");
} else if (tipo=="t") {
txt.Text=((TimeSpan)r[n]).ToString("hh\\:mm");
} else {
txt.Text=r[n].ToString();
}
}
}
}
protected void Guardar(object s, EventArgs e) {
try {
var nombres = new List<string>(); var valores = new List<string>(); var cambios = new List<string>(); var pars = new List<SqlParameter>();
int id = default(int);
int.TryParse(elegido.Value,out id);
foreach (var d in defs) {
var a = d.Split(':'); var n = a[0]; var tipo = a[1]; var c = Campo(n);
string raw = default(string);
if (c is TextBox) {
raw=((TextBox)c).Text.Trim();
} else {
raw=((DropDownList)c).SelectedValue;
}
if (n=="Clave" && id>0 && raw=="") continue;
if (raw=="" && n!="Observaciones") throw new Exception("Complete " + n);
object v = raw;
switch(tipo){
case "i":
v=int.Parse(raw); break;
case "m":
v=decimal.Parse(raw); break;
case "d": case "h":
v=DateTime.Parse(raw); break;
case "t":
v=TimeSpan.Parse(raw); break;
case "b":
v=(raw=="1"); break;
default:
if (tipo.StartsWith("r")) v=int.Parse(raw); break;
}
if (tipo=="i" && (int)v<0 || tipo=="m" && (decimal)v<0) throw new Exception("No se permiten valores negativos");
if (n=="Correo" && !System.Text.RegularExpressions.Regex.IsMatch(raw,"^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) throw new Exception("Correo inválido");
if (n=="Telefono" && !System.Text.RegularExpressions.Regex.IsMatch(raw,"^[0-9+ -]{8,20}$")) throw new Exception("Teléfono inválido");
if (n=="Clave") {
if (raw.Length<8) throw new Exception("La clave debe tener 8 caracteres como mínimo");
v=Hash(raw);
}
nombres.Add("[" + n + "]");
valores.Add("@" + n);
cambios.Add("[" + n + "]=@" + n);
pars.Add(P("@" + n,v));
}
if (entidad=="Empleados") {
var usuarioB = usuarioBarbero.Text.Trim();
if (usuarioB=="") throw new Exception("Ingrese el usuario del barbero");
if (claveBarbero.Text!=confirmarBarbero.Text) throw new Exception("Las contraseñas no coinciden");
if (claveBarbero.Text!="" && claveBarbero.Text.Length<8) throw new Exception("La contraseña debe tener al menos 8 caracteres");
if (id==0 && claveBarbero.Text=="") throw new Exception("Ingrese la contraseña del barbero");
pars.Add(P("@usuarioB",usuarioB));
pars.Add(P("@claveB",(claveBarbero.Text=="" ? "" : Hash(claveBarbero.Text))));
pars.Add(P("@id",id));
string sql = "SET XACT_ABORT ON; DECLARE @cuentaId int; SELECT @cuentaId=UsuarioId FROM UsuarioEmpleado WITH (UPDLOCK,HOLDLOCK) WHERE EmpleadoId=@id; " + "IF EXISTS(SELECT 1 FROM Usuarios WITH (UPDLOCK,HOLDLOCK) WHERE Usuario=@usuarioB AND (@cuentaId IS NULL OR Id<>@cuentaId)) THROW 50001,N'Este usuario ya existe. Elija otro nombre de usuario.',1; " + "IF @cuentaId IS NULL AND @claveB=N'' THROW 50002,N'Ingrese una contraseña para crear la cuenta.',1; ";
if (id==0) {
sql += "INSERT INTO Empleados (" + string.Join(",",nombres) + ") VALUES (" + string.Join(",",valores) + "); SET @id=CONVERT(int,SCOPE_IDENTITY()); ";
} else {
sql += "UPDATE Empleados SET " + string.Join(",",cambios) + " WHERE Id=@id; ";
}
sql += "IF @cuentaId IS NULL BEGIN INSERT INTO Usuarios(Nombre,Usuario,Clave,Rol,Activo) VALUES(@Nombre+' '+@Apellido,@usuarioB,@claveB,'Barbero',@Activo); SET @cuentaId=CONVERT(int,SCOPE_IDENTITY()); INSERT INTO UsuarioEmpleado(UsuarioId,EmpleadoId) VALUES(@cuentaId,@id); END ELSE BEGIN UPDATE Usuarios SET Nombre=@Nombre+' '+@Apellido,Usuario=@usuarioB,Activo=@Activo,Clave=CASE WHEN @claveB=N'' THEN Clave ELSE @claveB END WHERE Id=@cuentaId; END;";
GuardarOperacion(sql,pars.ToArray());
usuarioBarbero.Text="";
claveBarbero.Text="";
confirmarBarbero.Text="";
} else if (id==0) {
Ejecutar("INSERT INTO " + entidad + " (" + string.Join(",",nombres) + ") VALUES (" + string.Join(",",valores) + ")",pars.ToArray());
} else {
pars.Add(P("@id",id));
Ejecutar("UPDATE " + entidad + " SET " + string.Join(",",cambios) + " WHERE Id=@id",pars.ToArray());
}
cuenta.Visible=(entidad=="Empleados");
elegido.Value="";
mensaje.Text="Registro guardado.";
Cargar();
foreach (var d in defs) {
var c = Campo(d.Split(':')[0]);
if (c is TextBox) ((TextBox)c).Text="";
}
} catch (SqlException ex) {
if (ex.Number==50001 || ex.Number==2601 || ex.Number==2627) {
mensaje.Text=Server.HtmlEncode(ex.Message);
} else if (ex.Number==50002) {
mensaje.Text="Ingrese una contraseña para crear la cuenta.";
} else {
mensaje.Text="No se pudo guardar el registro. Verifique los datos.";
}
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
protected void Eliminar(object s, EventArgs e) {
try {
int id = default(int);
if (!int.TryParse(elegido.Value,out id)) throw new Exception("Seleccione un registro");
if (entidad=="Usuarios" && Tabla("SELECT Id FROM Usuarios WHERE Id=@id AND Usuario=@u",P("@id",id),P("@u",User.Identity.Name)).Rows.Count>0) throw new Exception("No puede eliminar su usuario");
Ejecutar("DELETE FROM " + entidad + " WHERE Id=@id",P("@id",id));
elegido.Value="";
Cargar();
mensaje.Text="Registro eliminado.";
} catch (Exception ex) {
mensaje.Text="No se pudo eliminar. " + Server.HtmlEncode(ex.Message);
}
}
protected void Nuevo(object s, EventArgs e) {
Response.Redirect("Gestion.aspx?t=" + entidad);
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1><asp:Literal ID="titulo" runat="server"/></h1><div class="panel"><asp:HiddenField ID="elegido" runat="server"/><asp:Panel ID="editor" runat="server"/><asp:Panel ID="cuenta" runat="server" Visible="false"><h2>Cuenta del barbero</h2><label>Usuario</label><asp:TextBox ID="usuarioBarbero" runat="server" MaxLength="200"/><label>Contraseña</label><asp:TextBox ID="claveBarbero" runat="server" TextMode="Password"/><label>Confirmar contraseña</label><asp:TextBox ID="confirmarBarbero" runat="server" TextMode="Password"/></asp:Panel><asp:Button runat="server" Text="Guardar" OnClick="Guardar"/><asp:Button runat="server" Text="Eliminar" OnClick="Eliminar" OnClientClick="return confirm('¿Eliminar registro?');"/><asp:Button runat="server" Text="Nuevo" OnClick="Nuevo"/><asp:Label ID="mensaje" runat="server" CssClass="mensaje"/></div><div class="panel"><input type="search" placeholder="Buscar registros" oninput="filtrar(this.value)"/><asp:GridView ID="grilla" runat="server" DataKeyNames="Id" AutoGenerateSelectButton="true" OnSelectedIndexChanged="Seleccionar" EmptyDataText="Sin registros"/><script>function filtrar(v){document.querySelectorAll('table tr').forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(v.toLowerCase())?'':'none'})}</script></div></asp:Content>