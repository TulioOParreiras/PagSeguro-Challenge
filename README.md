# PagSeguro-Challenge
PagSeguro iOS Dev Interview Job Challenge

## Beer List Feature Specs

### Story: Customer request to see the beer list

### Narrative #1

```
As an online customer
I want the app to automatically load the beer list
So I can see all the beers
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see the beer list
 Then the app should display the beers from remote
 
 Given the customer doesn't have connectivity
  When the customer requests to see the beer list
  Then the app should display an error message
```

### Use Cases

### Load Beer List From Remote Use Case

### Data:
- URL

##### Primary course (happy path):
1. Execute "Load Beer List" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates beer list from valid data.
5. System delivers beer list.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

### Load Beer Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

## Model Specs

### Feed Image

| Property      | Type                |
|---------------|---------------------|
| `id`          | `Int`              |
| `name` | `String`               |
| `tagline`    | `String`               |
| `description`    | `String`               |
| `image_url`    | `URL`               |
| `abv`            | `Double`               |
| `ibu`            | `Double`               |

### Payload contract

```
GET /beers

200 RESPONSE
[
    {
        "id": 0,
        "name": "a name",
        "tagline": "a tagline",
        "description": "a description",
        "image_url": "https://a-image-url.com",
        "abv": 0,
        "ibu": 0
    },
    {
        "id": 1,
        "name": "another name",
        "tagline": "another tagline",
        "description": "another description",
        "image_url": "https://another-image-url.com",
        "abv": 1,
        "ibu": 1
    }
    ...
]

```

