import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np 
import seaborn as sns
df=pd.read_csv('C:\\Users\devis\\OneDrive\\Desktop\\sql project\\insights\\customer_full_insights.txt')
print(df.head())
print(df.info())    
print(df.describe())
print(df.columns)
print(df.isnull().sum())
# Create churn label
# One-time customer = churned (0)
# Repeat customer   = retained (1)
df['repeat_customer'] = df['total_orders'].apply(
    lambda x: 0 if x == 1 else 1
)
#overall churn percentage
churn_rate = df['repeat_customer'].value_counts(normalize=True)[0] * 100
print(f"Overall Churn Rate: {churn_rate:.2f}%")
#compare experience 
churn_reason_table = df.groupby('repeat_customer').agg({
    'average_delivery_delay_days': 'mean',
    'average_review_score': 'mean',
    'total_revenue': 'mean',
    'customer_id': 'count'
}).reset_index()

churn_reason_table['customer_type'] = churn_reason_table['repeat_customer'].map({
    0: 'One-time (Churned)',
    1: 'Repeat (Retained)'
})

print(churn_reason_table)
# Visualization
fig, axes = plt.subplots(2, 2, figsize=(12, 10))    
# Average Delay Days
axes[0, 0].bar(churn_reason_table['customer_type'], churn_reason_table['average_delivery_delay_days'], color=['red', 'green'])
axes[0, 0].set_title('Average Delay Days by Customer Type') 
axes[0, 0].set_ylabel('Average Delay Days')
# Average Review Score
axes[0, 1].bar(churn_reason_table['customer_type'], churn_reason_table ['average_review_score'], color=['red', 'green'])
axes[0, 1].set_title('Average Review Score by Customer Type')
axes[0, 1].set_ylabel('Average Review Score')  
# Actual Contribution
# Using logarithmic scale for better visualization
axes[1, 0].bar(churn_reason_table['customer_type'], churn_reason_table['total_revenue'], color=['red', 'green'])
axes[1, 0].set_title('Actual Contribution by Customer Type')        
axes[1, 0].set_ylabel('Actual Contribution')
axes[1, 0].set_yscale('log')    
# Customer Count
# Using logarithmic scale for better visualization
# Using logarithmic scale for better visualization
axes[1, 1].bar(churn_reason_table['customer_type'], churn_reason_table['customer_id'], color=['red', 'green'])
axes[1, 1].set_title('Customer Count by Customer Type') 
axes[1, 1].set_yscale('log')        
axes[1, 1].set_ylabel('Customer Count')
plt.tight_layout()
plt.show()
# Insights:
# Customers who churn tend to have higher average delay days and lower average review scores.
# They also contribute less financially compared to retained customers.
# Strategies to reduce churn could focus on improving delivery times and customer satisfaction.         
#one time customers and delay days comparision 
plt.figure(figsize=(6,4))
plt.boxplot(
    [
        df[df['repeat_customer']==0]['average_delivery_delay_days'],
        df[df['repeat_customer']==1]['average_delivery_delay_days']
    ],
    labels=['One-time Customers', 'Repeat Customers']
)
plt.ylabel('Average Delivery Delay (Days)')
plt.title('Delivery Delay by Customer Type')
plt.show()
#one time vs review score 
plt.figure(figsize=(6,4))
plt.boxplot(
    [
        df[df['repeat_customer']==0]['average_review_score'],
        df[df['repeat_customer']==1]['average_review_score']
    ],
    labels=['One-time Customers', 'Repeat Customers']
)
plt.ylabel('Average Review Score')
plt.title('Review Score by Customer Type')
plt.show()
# Correlation Analysis
correlation = df[
    ['average_delivery_delay_days',
     'average_review_score',
     'total_revenue',
     'repeat_customer']
].corr()
print(correlation)
#correlation heatmap
plt.figure(figsize=(8,6))
sns.heatmap(correlation, annot=True, cmap='coolwarm', fmt=".2f")
plt.title('Correlation Matrix') 
plt.show()