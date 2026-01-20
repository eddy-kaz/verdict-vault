# VerdictVault - Community Content Validation Protocol

[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue)](https://docs.stacks.co/clarity)
[![License](https://img.shields.io/badge/License-ISC-green)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-yellow)](https://vitest.dev/)

## 🌟 Overview

VerdictVault is a revolutionary blockchain-powered platform that transforms how digital content is discovered, evaluated, and monetized through collective intelligence and transparent community governance. Built on the Stacks blockchain using Clarity smart contracts, VerdictVault establishes a merit-based ecosystem where content quality is determined by community consensus rather than algorithmic bias.

## 🎯 Core Features

### 📝 Content Submission

- **Decentralized Curation**: Submit any digital content with metadata (headline, hyperlink, topic)
- **Anti-Spam Protection**: Configurable submission fees prevent low-quality submissions
- **Topic Categorization**: Pre-defined content categories (Technology, Science, Art, Politics, Sports)

### 🗳️ Community Evaluation

- **Democratic Appraisal**: Binary voting system (+1 for positive, -1 for negative)
- **Reputation System**: User credibility scores based on participation quality
- **Transparent Scoring**: All evaluations recorded on-chain for full transparency

### 💰 Creator Monetization

- **Direct Rewards**: Community members can tip creators directly with STX
- **Merit-Based Earnings**: Higher-rated content attracts more rewards
- **Transparent Transactions**: All gratuities tracked and verifiable

### 🛡️ Community Moderation

- **Decentralized Flagging**: Users can flag inappropriate content
- **Reputation-Weighted Moderation**: More credible users have greater moderation influence
- **Administrative Controls**: Emergency content removal capabilities

## 🏗️ Architecture

### Smart Contract Structure

```clarity
verdict-vault.clar
├── Constants & Errors
├── Data Storage Maps
│   ├── curated-items
│   ├── participant-appraisals
│   └── participant-credibility
├── Core Functions
│   ├── contribute-item
│   ├── appraise-item
│   ├── reward-originator
│   └── flag-item
├── Read-Only Functions
│   ├── retrieve-item-details
│   ├── retrieve-top-items
│   └── get-participant-credibility
└── Administrative Functions
    ├── adjust-submission-charge
    ├── expunge-item
    └── introduce-topic
```

### Data Models

#### Content Item

```clarity
{
  originator: principal,
  headline: (string-ascii 100),
  hyperlink: (string-ascii 200),
  topic: (string-ascii 20),
  publication-epoch: uint,
  appraisals: int,
  gratuities: uint,
  flags: uint
}
```

#### User Reputation

```clarity
{
  participant: principal,
  metric: int
}
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) v16 or higher
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/eddy-kaz/verdict-vault.git
   cd verdict-vault
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Development Workflow

1. **Start development environment**

   ```bash
   clarinet console
   ```

2. **Run tests with coverage**

   ```bash
   npm run test:report
   ```

3. **Watch mode for continuous testing**

   ```bash
   npm run test:watch
   ```

## 📖 Usage Examples

### Submitting Content

```clarity
;; Submit a new article about blockchain technology
(contract-call? .verdict-vault contribute-item 
  "Revolutionary Blockchain Innovation" 
  "https://example.com/blockchain-article" 
  "Technology")
```

### Evaluating Content

```clarity
;; Positively appraise item #1
(contract-call? .verdict-vault appraise-item u1 1)

;; Negatively appraise item #2
(contract-call? .verdict-vault appraise-item u2 -1)
```

### Rewarding Creators

```clarity
;; Send 100 microSTX tip to content creator
(contract-call? .verdict-vault reward-originator u1 u100)
```

### Retrieving Content

```clarity
;; Get details for item #1
(contract-call? .verdict-vault retrieve-item-details u1)

;; Get top 5 highest-rated items
(contract-call? .verdict-vault retrieve-top-items u5)
```

## 🔧 Configuration

### Protocol Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `submission-charge` | 10 microSTX | Fee required to submit content |
| `MIN_HYPERLINK_LENGTH` | 10 characters | Minimum URL length |
| `content-topics` | 5 predefined | Available content categories |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `ERR_UNAUTHORIZED_ACCESS` | Caller lacks required permissions |
| u101 | `ERR_INVALID_SUBMISSION` | Submission data validation failed |
| u103 | `ERR_NONEXISTENT_ITEM` | Referenced item doesn't exist |
| u104 | `ERR_INADEQUATE_BALANCE` | Insufficient STX balance |
| u108 | `ERR_INVALID_APPRAISAL` | Appraisal value not ±1 |

## 🧪 Testing

The project uses Vitest with Clarinet SDK for comprehensive testing:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Run tests in watch mode
npm run test:watch
```

### Test Coverage Areas

- ✅ Content submission validation
- ✅ Appraisal system functionality
- ✅ Reward distribution mechanics
- ✅ Administrative functions
- ✅ Error handling scenarios
- ✅ Edge cases and security

## 🔒 Security Considerations

### Input Validation

- All user inputs are validated against defined constraints
- URL length requirements prevent malformed links
- Topic validation ensures content categorization integrity

### Access Control

- Administrative functions restricted to protocol owner
- Users cannot flag their own content
- Balance checks prevent insufficient fund transactions

### Economic Security

- Submission fees discourage spam and low-quality content
- Reputation system incentivizes honest evaluation
- Transparent reward system prevents manipulation

## 🤝 Contributing

We welcome contributions from the community! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Write tests** for new functionality
4. **Ensure all tests pass**

   ```bash
   npm test
   ```

5. **Submit a pull request**

### Development Standards

- Follow Clarity best practices
- Maintain comprehensive test coverage
- Document all public functions
- Use descriptive variable names
- Include error handling

## 📋 Roadmap

### Phase 1: Core Protocol ✅

- [x] Basic content submission and evaluation
- [x] Reputation system implementation
- [x] Reward distribution mechanism
- [x] Community moderation features

### Phase 2: Enhanced Features 🚧

- [ ] Advanced reputation algorithms
- [ ] Delegated evaluation system
- [ ] Cross-chain content integration
- [ ] Mobile-friendly interface

### Phase 3: Ecosystem Expansion 📋

- [ ] Third-party integrations
- [ ] Advanced analytics dashboard
- [ ] Governance token implementation
- [ ] Multi-language support

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Documentation**: [Stacks Documentation](https://docs.stacks.co/)
- **Community**: [Stacks Discord](https://discord.gg/stacks)
- **Issues**: [GitHub Issues](https://github.com/eddy-kaz/verdict-vault/issues)

## 🏆 Acknowledgments

- Built with [Clarinet](https://github.com/hirosystems/clarinet)
- Powered by [Stacks Blockchain](https://www.stacks.co/)
- Inspired by the vision of decentralized content curation

---

**VerdictVault** - *Transforming digital content through collective intelligence*
