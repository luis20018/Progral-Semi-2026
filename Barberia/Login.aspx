<%@ Page Language="C#" Inherits="System.Web.UI.Page" %><%@ Import Namespace="System.Web.Security" %>
<script runat="server">
protected void Page_Init(object s, EventArgs e) {
Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
Response.Cache.SetNoStore();
}
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) {
FormsAuthentication.SignOut();
Session.Clear();
Session.Abandon();
usuario.Text="";
clave.Text="";
}
if (!IsPostBack && Request.QueryString["registro"]=="1") {
rol.SelectedValue="Cliente";
msg.Text="Cuenta creada. Ya puedes iniciar sesión.";
}
}
protected void CambiarRol(object s, EventArgs e) {
usuario.Text="";
clave.Text="";
msg.Text="";
}
protected void Entrar(object s, EventArgs e) {
if (string.IsNullOrWhiteSpace(usuario.Text) || string.IsNullOrWhiteSpace(clave.Text)) {
msg.Text="Ingresa tu usuario y contraseña.";
return;
}
try {
Datos.Inicializar();
var dt = Datos.Tabla("SELECT * FROM Usuarios WHERE Usuario=@u AND Activo=1 AND Rol=@r",Datos.P("@u",usuario.Text.Trim()),Datos.P("@r",rol.SelectedValue));
if (dt.Rows.Count==1 && Datos.Hash(clave.Text,Convert.ToString(dt.Rows[0]["Clave"]))==Convert.ToString(dt.Rows[0]["Clave"])) {
Session.Clear();
Session["AccesoValidado"]=Convert.ToString(dt.Rows[0]["Usuario"]);
FormsAuthentication.SetAuthCookie(Convert.ToString(dt.Rows[0]["Usuario"]),false);
Response.Redirect((rol.SelectedValue=="Administrador" ? "Default.aspx" : "MiPortal.aspx"),false);
} else {
msg.Text="Usuario, contraseña o tipo de acceso incorrectos.";
}
} catch (Exception ex) {
msg.Text="No se pudo iniciar: " + Server.HtmlEncode(ex.Message);
}
}
</script><!DOCTYPE html><html lang="es"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/><title>Barbería | Acceso</title><link rel="stylesheet" href="estilo.css"/></head><body class="login-page"><form runat="server" class="login"><div class="login-brand">✂</div><div class="eyebrow">ESTILO Y PRECISIÓN</div><h1>Barbería</h1><h2>Iniciar sesión</h2><p>Selecciona tu tipo de acceso.</p><asp:RadioButtonList ID="rol" runat="server" CssClass="roles" AutoPostBack="true" OnSelectedIndexChanged="CambiarRol" RepeatLayout="Flow" RepeatDirection="Horizontal"><asp:ListItem Value="Administrador" Selected="True">Dueño</asp:ListItem><asp:ListItem Value="Barbero">Barbero</asp:ListItem><asp:ListItem Value="Cliente">Cliente</asp:ListItem></asp:RadioButtonList><asp:TextBox ID="usuario" runat="server" placeholder="Usuario"/><asp:TextBox ID="clave" runat="server" TextMode="Password" placeholder="Contraseña"/><asp:Button runat="server" Text="Ingresar" OnClick="Entrar"/><asp:Label ID="msg" runat="server" CssClass="mensaje"/><p class="registro-link">¿No tienes cuenta? <a href="Registro.aspx">Crear cuenta de cliente</a></p></form></body></html>