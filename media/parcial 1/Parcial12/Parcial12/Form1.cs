using System;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace Parcial12
{
    public partial class Form1 : Form
    {
        // Matriz con los datos de la tabla (Desde, Hasta, Precio Base, Adicional)
        private readonly (decimal desde, decimal hasta, decimal precio, decimal adicional)[] tablaImpuestos =
        {
            (0.01m,       500.00m,     1.50m, 0.00m),
            (500.01m,     1000.00m,    1.50m, 3.00m),
            (1000.01m,    2000.00m,    3.00m, 3.00m),
            (2000.01m,    3000.00m,    6.00m, 3.00m),
            (3000.01m,    6000.00m,    9.00m, 2.00m),
            (6000.01m,   18000.00m,   15.00m, 2.00m),
            (18000.01m,  30000.00m,   39.00m, 2.00m),
            (30000.01m,  60000.00m,   63.00m, 1.00m),
            (60000.01m, 100000.00m,   93.00m, 0.80m),
            (100000.01m, 200000.00m, 125.00m, 0.70m),
            (200000.01m, 300000.00m, 195.00m, 0.60m),
            (300000.01m, 400000.00m, 255.00m, 0.45m),
            (400000.01m, 500000.00m, 300.00m, 0.40m),
            (500000.01m, 1000000.00m, 340.00m, 0.30m),
            (1000000.01m, 99999999.00m, 490.00m, 0.18m)
        };

        public Form1()
        {
            InitializeComponent();

            // Vinculación forzada de eventos para asegurar que los botones respondan
            this.button1.Click += new EventHandler(this.button1_Click);
            this.button2.Click += new EventHandler(this.button2_Click);
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (textBox2 != null) textBox2.Clear();
        }

        // Lógica del Botón Calcular
        private void button1_Click(object sender, EventArgs e)
        {
            // Elimina comas o espacios que puedan arruinar la conversión
            string textoLimpio = textBox1.Text.Trim().Replace(",", "");

            if (!decimal.TryParse(textoLimpio, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal monto) || monto < 0.01m)
            {
                MessageBox.Show("Ingrese un monto válido mayor a 0.", "Atención", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                textBox1.Focus();
                return;
            }

            // Selecciona el tramo correspondiente
            var tramo = tablaImpuestos.FirstOrDefault(t => monto >= t.desde && monto <= t.hasta);

            if (tramo == default)
            {
                MessageBox.Show("El monto ingresado está fuera de los rangos de la tabla.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // Fórmula: ((Monto - Desde) / 1000) * Adicional + Precio Base
            decimal excedente = monto - tramo.desde;
            decimal cuotaAdicional = (excedente / 1000m) * tramo.adicional;
            decimal totalImpuesto = cuotaAdicional + tramo.precio;

            // Redondeo
            decimal resultadoFinal = Math.Round(totalImpuesto, 2, MidpointRounding.AwayFromZero);

            // Asigna el resultado al textBox2
            textBox2.Text = $"${resultadoFinal:F2}";
        }

        // Lógica del Botón Limpiar
        private void button2_Click(object sender, EventArgs e)
        {
            textBox1.Clear();
            textBox2.Clear();
            textBox1.Focus();
        }
    }
}