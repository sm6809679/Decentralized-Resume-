# 📄 Decentralized Resume

A blockchain-powered resume platform built on the Stacks blockchain using Clarity smart contracts. Store your professional profile, work experience, education, and skills on-chain with complete ownership and privacy control.

## ✨ Features

- 🏗️ **Profile Management** - Create and update your professional profile
- 💼 **Work Experience** - Add up to 10 work experience entries
- 🎓 **Education** - Track your educational background
- 🔧 **Skills** - Showcase up to 20 professional skills
- 👥 **Endorsements** - Receive endorsements from other users
- 🔒 **Privacy Control** - Toggle profile visibility (public/private)
- 🌐 **Decentralized** - Your data lives on the blockchain, not on centralized servers

## 🚀 Quick Start

### Prerequisites

- [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
- [Stacks Wallet](https://www.hiro.so/wallet)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd decentralized-resume
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start Clarinet console:
   ```bash
   clarinet console
   ```

## 📋 Contract Functions

### Profile Management

#### Create Profile
```clarity
(contract-call? .decentralized-resume create-profile
  "John Doe"                    ;; name
  "Software Engineer"           ;; title
  "Passionate developer..."     ;; bio
  "john@example.com"           ;; email
  "+1234567890"                ;; phone
  "https://johndoe.dev"        ;; website
  "San Francisco, CA"          ;; location
  true)                        ;; is-public
```

#### Update Profile
```clarity
(contract-call? .decentralized-resume update-profile
  "John Doe"
  "Senior Software Engineer"
  "Updated bio..."
  "john@example.com"
  "+1234567890"
  "https://johndoe.dev"
  "San Francisco, CA"
  true)
```

### Work Experience

#### Add Work Experience
```clarity
(contract-call? .decentralized-resume add-work-experience
  "TechCorp Inc"               ;; company
  "Senior Developer"           ;; position
  "Led development team..."    ;; description
  "2022-01"                    ;; start-date
  "2024-01"                    ;; end-date
  false)                       ;; is-current
```

### Education

#### Add Education
```clarity
(contract-call? .decentralized-resume add-education
  "University of Tech"         ;; institution
  "Bachelor of Science"        ;; degree
  "Computer Science"           ;; field
  "2018-09"                    ;; start-date
  "2022-05"                    ;; end-date
  "3.8")                       ;; gpa
```

### Skills

#### Add Skill
```clarity
(contract-call? .decentralized-resume add-skill
  "JavaScript"                 ;; skill
  "Expert")                    ;; level
```

### Endorsements

#### Endorse User
```clarity
(contract-call? .decentralized-resume endorse-user
  'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C  ;; user principal
  "John is an excellent developer...")         ;; message
```

### Privacy Control

#### Set Profile Visibility
```clarity
(contract-call? .decentralized-resume set-profile-visibility true)  ;; public
(contract-call? .decentralized-resume set-profile-visibility false) ;; private
```

## 🔍 Read Functions

### Get Profile Data
```clarity
(contract-call? .decentralized-resume get-profile 'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C)
```

### Get Work Experience
```clarity
(contract-call? .decentralized-resume get-work-experience 
  'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C  ;; user
  u0)                                          ;; index
```

### Get Education
```clarity
(contract-call? .decentralized-resume get-education 
  'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C  ;; user
  u0)                                          ;; index
```

### Get Skills
```clarity
(contract-call? .decentralized-resume get-skill
  'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C  ;; user
  u0)                                          ;; index
```

### Get User Counters
```clarity
(contract-call? .decentralized-resume get-user-counters
  'SP1HTBVD3JG9C05J7HDJKDYR94D9P6ZZ26V4J4E2C)
```

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

## 🏗️ Architecture

The smart contract uses several data maps to organize user data:

- **user-profiles**: Core profile information
- **work-experience**: Work history entries
- **education**: Educational background
- **user-skills**: Professional skills
- **endorsements**: Peer endorsements
- **user-counters**: Track entry counts per user

## 📊 Limitations

- Maximum 10 work experience entries per user
- Maximum 10 education entries per user  
- Maximum 20 skills per user
- String length limits enforced for data integrity

## 🛡️ Security Features

- Only profile owners can modify their data
- Users cannot endorse themselves
- Input validation for all functions
- Privacy controls for profile visibility

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

---

**Built with ❤️ on Stacks blockchain**
