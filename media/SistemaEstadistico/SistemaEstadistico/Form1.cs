using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace SistemaEstadistico
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // Cargar las opciones en el ComboBox1
            comboBox1.Items.Clear();
            comboBox1.Items.Add("Edades");
            comboBox1.Items.Add("Tiempo de traslado a la UGB");
            comboBox1.Items.Add("Horas de uso del teléfono");

            if (comboBox1.Items.Count > 0)
                comboBox1.SelectedIndex = 0;

            LimpiarTodo();
        }

        // Evento del Botón Calcular (button1)
        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                // 1. Validar que el TextBox1 de entrada no esté vacío
                string entrada = textBox1.Text.Trim();
                if (string.IsNullOrEmpty(entrada))
                {
                    MessageBox.Show("Por favor, ingrese los datos separados por comas.", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // 2. Convertir la cadena a lista de números
                List<double> datos = entrada.Split(new char[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries)
                                           .Select(s => Convert.ToDouble(s.Trim()))
                                           .OrderBy(n => n)
                                           .ToList();

                if (datos.Count == 0)
                {
                    MessageBox.Show("No se encontraron números válidos.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                // 3. CÁLCULOS ESTADÍSTICOS

                // Media Aritmética
                double media = datos.Average();

                // Mediana
                double mediana;
                int totalElementos = datos.Count;
                if (totalElementos % 2 == 0)
                {
                    mediana = (datos[(totalElementos / 2) - 1] + datos[totalElementos / 2]) / 2.0;
                }
                else
                {
                    mediana = datos[totalElementos / 2];
                }

                // Moda
                var frecuencias = datos.GroupBy(x => x)
                                       .Select(g => new { Valor = g.Key, Conteo = g.Count() })
                                       .ToList();

                int maxFrecuencia = frecuencias.Max(f => f.Conteo);
                string stringModa;

                if (maxFrecuencia == 1 && datos.Count > 1)
                {
                    stringModa = "No hay moda";
                }
                else
                {
                    var modas = frecuencias.Where(f => f.Conteo == maxFrecuencia)
                                           .Select(f => f.Valor.ToString("0.##"));
                    stringModa = string.Join(", ", modas);
                }

                // Varianza
                double sumaDiferenciasCuadrado = datos.Sum(d => Math.Pow(d - media, 2));
                double varianza = totalElementos > 1 ? sumaDiferenciasCuadrado / (totalElementos - 1) : 0;

                // Desviaciones
                double desvEstandar = Math.Sqrt(varianza);
                double desvTipica = desvEstandar;

                // Rango
                double rango = datos.Max() - datos.Min();

                // 4. MOSTRAR RESULTADOS EN LOS TEXTBOX

                textBox2.Text = media.ToString("F2");        // Media Aritmética
                textBox3.Text = mediana.ToString("F2");      // Mediana
                textBox4.Text = stringModa;                   // Moda
                textBox5.Text = varianza.ToString("F2");     // Varianza
                textBox6.Text = desvEstandar.ToString("F2"); // Desviación Estándar
                textBox7.Text = desvTipica.ToString("F2");   // Desviación Típica
                textBox8.Text = rango.ToString("F2");        // Rango

                // 5. ACTUALIZAR TABLA Y GRÁFICO
                LlenarTablaFrecuencia(frecuencias, totalElementos);
                GraficarFrecuencia(frecuencias);
            }
            catch (FormatException)
            {
                MessageBox.Show("Asegúrese de ingresar únicamente números separados por comas.", "Error de formato", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ocurrió un error: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // Método para construir la Tabla de Frecuencias en dataGridView1
        private void LlenarTablaFrecuencia(dynamic frecuencias, int totalDatos)
        {
            dataGridView1.Rows.Clear();
            dataGridView1.Columns.Clear();

            dataGridView1.Columns.Add("Valor", "Valor");
            dataGridView1.Columns.Add("Frecuencia", "Frecuencia");
            dataGridView1.Columns.Add("FrecuenciaRelativa", "Frecuencia Relativa");
            dataGridView1.Columns.Add("FrecuenciaAcumulada", "Frecuencia Acumulada");

            double frecAcumulada = 0;

            foreach (var item in frecuencias)
            {
                double val = item.Valor;
                int frecAbsoluta = item.Conteo;
                double frecRelativa = (double)frecAbsoluta / totalDatos;
                frecAcumulada += frecRelativa;

                dataGridView1.Rows.Add(
                    val.ToString("0.0"),
                    frecAbsoluta,
                    frecRelativa.ToString("F2"),
                    frecAcumulada.ToString("F2")
                );
            }

            dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }

        // Método para graficar en chart1
        private void GraficarFrecuencia(dynamic frecuencias)
        {
            chart1.Series.Clear();
            chart1.Titles.Clear();

            Series series = new Series("Frecuencia")
            {
                ChartType = SeriesChartType.Column
            };

            foreach (var item in frecuencias)
            {
                series.Points.AddXY(item.Valor.ToString("0.0"), item.Conteo);
            }

            chart1.Series.Add(series);

            if (chart1.ChartAreas.Count > 0)
            {
                chart1.ChartAreas[0].AxisX.Title = "Valor";
                chart1.ChartAreas[0].AxisY.Title = "Frecuencia";
                chart1.ChartAreas[0].AxisX.Interval = 1;
            }
        }

        // Evento del Botón Limpiar (button2)
        private void button2_Click(object sender, EventArgs e)
        {
            LimpiarTodo();
        }

        // Método para reiniciar todos los campos y controles
        private void LimpiarTodo()
        {
            // Entrada de datos
            textBox1.Clear();

            // Resultados
            textBox2.Text = "0.00"; // Media Aritmética
            textBox3.Text = "0.00"; // Mediana
            textBox4.Text = "-";    // Moda
            textBox5.Text = "0.00"; // Varianza
            textBox6.Text = "0.00"; // Desviación Estándar
            textBox7.Text = "0.00"; // Desviación Típica
            textBox8.Text = "0.00"; // Rango

            // Tabla y Gráfico
            dataGridView1.Rows.Clear();
            dataGridView1.Columns.Clear();

            chart1.Series.Clear();
            chart1.Titles.Clear();
        }

        // Filtro para aceptar solo números, comas, puntos y espacios en textBox1
        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) &&
                e.KeyChar != ',' && e.KeyChar != '.' && e.KeyChar != ' ')
            {
                e.Handled = true;
            }
        }
    }
}