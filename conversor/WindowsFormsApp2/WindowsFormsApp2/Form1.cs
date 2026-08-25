using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace WindowsFormsApp2
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        // Matriz con las unidades desplegables
        String[][] etiquetas = {
            new string[]{"Metros", "Cm", "Pulgadas", "Pies", "Varas", "Yardas", "Km", "Millas"},
            new string[]{"Dolar", "Quetzal", "Lempira", "Cordobas", "Colon CR"}
        };

        // Matriz con las equivalencias
        Double[][] valores = {
            new double[]{1, 100, 39.3701, 3.28084, 1.1963, 1.09361, 0.001, 0.000621371},
            new double[]{1, 7.63, 26.81, 36.80, 449.23}
        };

        private void Form1_Load(object sender, EventArgs e)
        {
            comboBox1.Items.Clear();
            comboBox1.Items.Add("Longitud");
            comboBox1.Items.Add("Monedas");
            comboBox1.SelectedIndex = 0;
        }

        private void comboBox1_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            comboBox2.Items.Clear();
            comboBox3.Items.Clear();

            int opcion = comboBox1.SelectedIndex;

            if (opcion >= 0 && opcion < etiquetas.Length)
            {
                comboBox2.Items.AddRange(etiquetas[opcion]);
                comboBox3.Items.AddRange(etiquetas[opcion]);

                comboBox2.SelectedIndex = 0;
                comboBox3.SelectedIndex = 0;
            }
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            try
            {
                int de = comboBox2.SelectedIndex;
                int a = comboBox3.SelectedIndex;
                int opcion = comboBox1.SelectedIndex;

                if (de != -1 && a != -1 && opcion != -1)
                {
                    double cantidad = Double.Parse(textBox1.Text);
                    double respuesta = valores[opcion][a] / valores[opcion][de] * cantidad;

                    label5.Text = respuesta.ToString();
                }
                else
                {
                    MessageBox.Show("Selecciona las opciones para realizar la conversión.");
                }
            }
            catch (Exception)
            {
                MessageBox.Show("Ingresa una cantidad numérica válida.");
            }
        }
    }
}