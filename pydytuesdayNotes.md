# PyDyTuesday

## 05/13/25 Mount Vesuvius
When I first checked the data, I noticed that some data was missing. At first, it seemed like the missing data was just in preliminary and figured it was data that would be later revised inside the data set.

I looked at the distinct values in the "review_level" column to see if the missing data was just a case of "preliminary" and there was a third value in the variable that would somehow have better quality data.

I found that all the data values were just "revised" and "preliminary" for that variable. 

I then grouped the data by "revised" and "preliminary" to see where the values were aligning and found that only a couple of data rows were "revised".

They were in only two years of data, each having only one record.  I filtered out both the NaN rows and the "revised" rows.

The number of rows with NaN data deleted about 3,000 data records, which out of 12,000, is a significant chunk.

However, my intention was to do descriptive statistics rather than read trends in the data (I'm getting there very slowly in the certificate), but also not to use the data to read in generalizations of Mt. Vesuvius. 

Once the data was "cleaned", I analysed the data once more for variables I could use and perform some simple calculations with the data, which I chose "depth_km" and "magnitude". Because I have learned that the median is often a better descriptor than the mean, I calculated the median of the variables I chose.

I then plotted the two lines on the same plot with different axes. While the data needs more validation and perhaps more data points, there seems to be rough trends in both the depth of the median depth and magnitude, suggesting that Earth's processes, especially for volcanic earthquakes, and thus making it easier to predict when more descructive ones will happen and offset the level of harm and destruction.


ETA: I  never saved the .dropna() dataframe and thus changed my previous graph because while "depth_km" remained unaffected, "duration_magnitude_md" plot line changed dramatically! Oops!

Graph:

![pydytuesday05 13 25](https://github.com/user-attachments/assets/f355bebf-9bfb-4e31-8a89-9321b3df726f)

Code: 

```
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import datetime as dt

df = pd.read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-05-13/vesuvius.csv')
df.head()
df.shape
df.info()
df['review_level'].unique()
df.isna()
df.groupby(['review_level', 'year']).count()

df_13to24 = df[df['year'].isin([2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024])]
df_13to24.head()
df_13to24 = df_13to24.dropna().reset_index()
df_median = df_13to24.groupby('year').agg({'depth_km':'median',
                                           'duration_magnitude_md': 'median'
                                           }).reset_index()
df_median
x = df_median['year']
y1 = df_median['depth_km']
y2 = df_median['duration_magnitude_md']

fig, ax1 = plt.subplots()

ax1.plot(x, y1, 'g-', label = 'Depth in km')
ax1.set_xlabel('Year')
ax1.set_ylabel('Median Depth in km', color ='g')
ax1.tick_params(axis = 'y', labelcolor = 'green')

ax2 = ax1.twinx()

ax2.plot(x, y2, 'b-', label = 'Magnitude')
ax2.set_xlabel('Year')
ax2.set_ylabel('Median Magnitude', color = 'b')
ax2.tick_params(axis = 'y', labelcolor = 'blue')

plt.title('Median Depth and Magitudes of Earthquakes at Mt. Vesuvius')

fig.tight_layout()
plt.savefig('Downloads/pydytuesday05.13.25.png')
plt.show()
```
