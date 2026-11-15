
# Закупки

```mermaid
erDiagram
    bm_JournalBarnetDocs ||--o{ bm_StorageOperations : "DocumentID"
    bm_StorageOperationsType ||--o{ bm_StorageOperations : "OperationID"
    product ||--o{ bm_StorageOperations : "ProductID"
    storages ||--o{ bm_StorageOperations : "StorageID"

    bm_JournalBarnetDocs {
        int ID PK
    }

    bm_StorageOperations {
        int ID PK
        int DocumentID FK
        int OperationID FK
        int ProductID FK
        int StorageID FK
        int VendorID
        decimal Quantity
        decimal Amount
        datetime DateAdd
    }

    bm_StorageOperationsType {
        int ID PK
        string Name
    }

    product {
        int id PK
        string description
    }

    storages {
        int id PK
    }

    vendors {
        int id
        string firstname
    }
```
