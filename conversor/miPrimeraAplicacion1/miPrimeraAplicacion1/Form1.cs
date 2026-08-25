using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace miPrimeaAplicacion
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        // Matriz con los nombres de las unidades
        String[][] etiquetas = {
            new string[]{"Metros", "Cm", "Pulgadas", "Pies", "Varas", "Yardas", "Km", "Millas"}, // Longitud
            new string[]{"Dolar", "Quetzal", "Lempira", "Cordobas", "Colon CR"} // Monedas
        };

        // Matriz con las equivalencias
        Double[][] valores = {
            new double[]{1, 100, 39.3701, 3.28084, 1.1963, 1.09361, 0.001, 0.000621371}, // Longitud
            new double[]{1, 7.63, 26.81, 36.80, 449.23} // Monedas
        };

        private void Form1_Load(object sender, EventArgs e)
        {
            // Opcional: Cargar categorías si no las agregaste desde la propiedad Items del diseñador
            if (comboBox1.Items.Count == 0)
            {
                comboBox1.Items.Add("Longitud");
                comboBox1.Items.Add("Monedas");
            }
        }

        // Evento del botón Calcular (button1)
        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                int de = comboBox2.SelectedIndex;
                int a = comboBox3.SelectedIndex;
                int opcion = comboBox1.SelectedIndex;

                if (de != -1 && a != -1 && opcion != -1)
                {
                    double cantidad = Double.Parse(textBox1.Text);

                    // Fórmula de conversión
                    double respuesta = valores[opcion][a] / valores[opcion][de] * cantidad;

                    // Muestra el resultado (cambia label5 si tu etiqueta de resultado tiene otro nombre)
                    label5.Text = respuesta.ToString("N4");
                }
                else
                {
                    MessageBox.Show("Por favor selecciona todas las opciones de conversión.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ingresa una cantidad numérica válida: " + ex.Message);
            }
        }

        // Evento de cambio de opción en comboBox1 (Opciones)
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Limpiamos las listas anteriores
            comboBox2.Items.Clear();
            comboBox3.Items.Clear();

            // Asignamos las nuevas unidades según la categoría seleccionada
            int opcion = comboBox1.SelectedIndex;
            if (opcion >= 0 && opcion < etiquetas.Length)
            {
                comboBox2.Items.AddRange(etiquetas[opcion]);
                comboBox3.Items.AddRange(etiquetas[opcion]);
            }
        }
    }
}