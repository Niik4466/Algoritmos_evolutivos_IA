import pandas as pd
import matplotlib.pyplot as plt

# Cargar el CSV
df = pd.read_csv('datosPSO.csv')

# Crear el gráfico sin marcadores
plt.figure(figsize=(10, 6))
plt.plot(df['medias'], label='Fitness Promedio', linewidth=2)
plt.plot(df['minimos'], label='Fitness Mínimo', linewidth=2)

# Personalizar el gráfico
plt.title('Evolución del Fitness por Iteracion')
plt.xlabel('Iteracion')
plt.ylabel('Fitness')
plt.legend()
plt.grid(True)
plt.tight_layout()

# Mostrar el gráfico
plt.show()
