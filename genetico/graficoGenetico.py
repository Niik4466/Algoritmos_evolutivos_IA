import pandas as pd
import matplotlib.pyplot as plt

# Cargar el CSV
df = pd.read_csv('datosGeneticos.csv')

# Crear el gráfico
plt.figure(figsize=(10, 6))
plt.plot(df['minimos'], label='Fitness Mínimo')
plt.plot(df['medias'], label='Fitness Promedio')

# Personalizar el gráfico
plt.title('Evolución del Fitness por Generación')
plt.xlabel('Generación')
plt.ylabel('Fitness')
plt.legend()
plt.grid(True)
plt.tight_layout()

# Mostrar el gráfico
plt.show()
