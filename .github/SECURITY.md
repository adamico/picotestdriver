# Security Policy

## Supported Versions

We take security seriously. This section outlines which versions of our project are currently supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please help us by reporting it responsibly.

### How to Report

Please **DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security vulnerabilities by emailing [your-email@example.com] with the following information:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact of the vulnerability
- Any suggested fixes or mitigations

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt of your report within 48 hours
- **Investigation**: We'll investigate the issue and work on a fix
- **Updates**: We'll keep you informed about our progress
- **Disclosure**: Once fixed, we'll coordinate disclosure with you

### Responsible Disclosure

We kindly ask that you:
- Give us reasonable time to fix the issue before public disclosure
- Avoid accessing or modifying user data
- Don't perform DoS attacks or degrade service performance

## Security Best Practices for Users

When using this testing framework:

1. **Validate test code**: Always review generated test code before execution
2. **Limit test scope**: Run tests in isolated environments when possible
3. **Monitor resource usage**: Be aware of PICO-8's token and memory limitations
4. **Keep dependencies updated**: Use the latest versions of PICO-8 and related tools

## Security Considerations for Contributors

When contributing to this project:

1. **Code review**: All changes undergo security review
2. **Input validation**: Validate all inputs and parameters
3. **Error handling**: Implement proper error handling without information leakage
4. **Dependencies**: Keep dependencies minimal and well-audited

Thank you for helping keep our project and community safe!