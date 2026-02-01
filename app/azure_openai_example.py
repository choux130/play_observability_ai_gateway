# %%
#!/usr/bin/env python3
"""
Simple example of calling Azure OpenAI API using the openai Python library.

Prerequisites:
    pip install openai python-dotenv

Set environment variables or use .env file:
    AZURE_OPENAI_ENDPOINT=https://your-service.openai.azure.com/
    AZURE_OPENAI_KEY=your-api-key
    AZURE_OPENAI_DEPLOYMENT=gpt-4o-mini
"""

import os
from openai import AzureOpenAI
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# %%
def main():
    """Main function to demonstrate Azure OpenAI API call."""
    
    # Initialize Azure OpenAI client
    # These values should come from Terraform outputs
    client = AzureOpenAI(
        api_key=os.getenv("AZURE_OPENAI_KEY"),
        api_version="2024-02-01",  # API version
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
    )
    
    deployment_name = os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-4o-mini")
    
    print(f"Using deployment: {deployment_name}")
    print(f"Endpoint: {os.getenv('AZURE_OPENAI_ENDPOINT')}")
    print("-" * 50)
    
    # Example 1: Simple completion
    print("\n[Example 1: Simple Completion]")
    response = client.chat.completions.create(
        model=deployment_name,
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What is Azure OpenAI Service?"}
        ],
        max_completion_tokens=150,
    )
    
    print(f"Response: {response.choices[0].message.content}")
    print(f"Tokens used: {response.usage.total_tokens}")
    
    # Example 2: Conversation with multiple turns
    print("\n[Example 2: Multi-turn Conversation]")
    messages = [
        {"role": "system", "content": "You are a helpful Python programming assistant."},
        {"role": "user", "content": "How do I read a CSV file in Python?"},
    ]
    
    response = client.chat.completions.create(
        model=deployment_name,
        messages=messages,
        max_completion_tokens=200,
    )
    
    assistant_message = response.choices[0].message.content
    print(f"Assistant: {assistant_message}")
    
    # Continue the conversation
    messages.append({"role": "assistant", "content": assistant_message})
    messages.append({"role": "user", "content": "Can you show me a simple example?"})
    
    response = client.chat.completions.create(
        model=deployment_name,
        messages=messages,
        max_completion_tokens=250,
    )
    
    print(f"\nAssistant: {response.choices[0].message.content}")
    print(f"Total tokens: {response.usage.total_tokens}")
    
    # Example 3: Streaming response
    print("\n[Example 3: Streaming Response]")
    print("Assistant (streaming): ", end="", flush=True)
    
    stream = client.chat.completions.create(
        model=deployment_name,
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Count from 1 to 5."}
        ],
        max_completion_tokens=100,
        stream=True
    )
    
    for chunk in stream:
        if chunk.choices and chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)
    print("\n")

# %%
if __name__ == "__main__":
    # Check if required environment variables are set
    required_vars = ["AZURE_OPENAI_ENDPOINT", "AZURE_OPENAI_KEY"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}")
        print("\nPlease set them in your .env file or environment:")
        print("  AZURE_OPENAI_ENDPOINT=https://your-service.openai.azure.com/")
        print("  AZURE_OPENAI_KEY=your-api-key")
        print("  AZURE_OPENAI_DEPLOYMENT=gpt-5-mini")
        exit(1)
    
    main()
