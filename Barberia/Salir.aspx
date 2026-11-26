<%@ Page Language="C#" Inherits="PaginaBase" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
System.Web.Security.FormsAuthentication.SignOut();
Session.Clear();
Session.Abandon();
Response.Redirect("Login.aspx");
}
</script>