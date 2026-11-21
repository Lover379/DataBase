
# ABC-анализ товаров

```mermaid id="abc123"
erDiagram
    category ||--o{ product : "CategoryID"

    product ||--o{ journal : "id / ProductID"

    product {
        int id PK
        string description
        int CategoryID FK
        decimal cost
    }

    category {
        int id PK
    }

    journal {
        int id
        datetime dater
        int transtype FK
        decimal amount
        decimal quantity
    }

    transtype {
        int transtypeid PK
    }
```
