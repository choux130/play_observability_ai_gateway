#!/usr/bin/env python3
# %%
"""
Azure OpenAI with Self-Hosted Local Langfuse

This example connects to your locally running Langfuse instance.
All data stays on your machine - no external connections.

Prerequisites:
    1. Run Langfuse locally: ./setup-langfuse-3.sh
    2. Create account at http://localhost:3000
    3. Get API keys from Langfuse Settings → API Keys
    4. pip install openai python-dotenv langfuse

Environment variables needed:
    AZURE_OPENAI_ENDPOINT=https://your-service.openai.azure.com/
    AZURE_OPENAI_KEY=your-api-key
    AZURE_OPENAI_DEPLOYMENT=gpt-5-mini
    
    # Local Langfuse (note the localhost URL!)
    LANGFUSE_PUBLIC_KEY=pk-lf-...
    LANGFUSE_SECRET_KEY=sk-lf-...
    LANGFUSE_BASE_URL=http://localhost:3000  # IMPORTANT: Local URL!
"""

import os
# from openai import AzureOpenAI
from langfuse.openai import AzureOpenAI as LangfuseAzureOpenAI
from langfuse import Langfuse
from dotenv import load_dotenv
import inspect

load_dotenv()


# %%
def main():
    # Initialize Azure OpenAI client
    # These values should come from Terraform outputs
    client = LangfuseAzureOpenAI(
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
        max_completion_tokens=3000,
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
        max_completion_tokens=3000,
    )
    
    assistant_message = response.choices[0].message.content
    print(f"Assistant: {assistant_message}")
    
    # Continue the conversation
    messages.append({"role": "assistant", "content": assistant_message})
    messages.append({"role": "user", "content": "Can you show me a simple example?"})
    
    response = client.chat.completions.create(
        model=deployment_name,
        messages=messages,
        max_completion_tokens=3000,
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
        max_completion_tokens=3000,
        stream=True
    )
    
    for chunk in stream:
        if chunk.choices and chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)
    print("\n")



if __name__ == "__main__":
    # Check required environment variables
    required_vars = [
        "AZURE_OPENAI_ENDPOINT",
        "AZURE_OPENAI_KEY",
        "LANGFUSE_PUBLIC_KEY",
        "LANGFUSE_SECRET_KEY"
    ]
    
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"❌ Error: Missing required environment variables: {', '.join(missing_vars)}")
        print("\nPlease set them in your .env file:")
        print("\n# Azure OpenAI")
        print("AZURE_OPENAI_ENDPOINT=https://your-service.openai.azure.com/")
        print("AZURE_OPENAI_KEY=your-api-key")
        print("AZURE_OPENAI_DEPLOYMENT=gpt-5-mini")
        print("\n# Local Langfuse")
        print("LANGFUSE_PUBLIC_KEY=pk-lf-...")
        print("LANGFUSE_SECRET_KEY=sk-lf-...")
        print("LANGFUSE_BASE_URL=http://localhost:3000  # IMPORTANT: localhost!")
        print("\n💡 Steps:")
        print("   1. Run: ./setup-langfuse.sh")
        print("   2. Open: http://localhost:3000")
        print("   3. Sign up and get your API keys")
        print("   4. Add keys to .env file")
        exit(1)
    
    # Verify LANGFUSE_BASE_URL is set to localhost
    LANGFUSE_BASE_URL = os.getenv("LANGFUSE_BASE_URL", "")
    if not LANGFUSE_BASE_URL:
        print("⚠️  LANGFUSE_BASE_URL not set!")
        print("   Add to .env: LANGFUSE_BASE_URL=http://localhost:3000")
        exit(1)
    
    main()


# %%
# from langfuse import get_client
# from dotenv import load_dotenv
# load_dotenv()

# langfuse = get_client()

# # %%
# # Create a span using a context manager
# with langfuse.start_as_current_observation(as_type="span", name="process-request") as span:
#     # Your processing logic here
#     span.update(output="Processing complete")
 
#     # Create a nested generation for an LLM call
#     with langfuse.start_as_current_observation(as_type="generation", name="llm-response", model="gpt-3.5-turbo") as generation:
#         # Your LLM call logic here
#         generation.update(output="Generated response")
 
# # All spans are automatically closed when exiting their context blocks
 
 
# # Flush events in short-lived applications
# langfuse.flush()

# # %%
# with langfuse.start_as_current_observation(as_type="span", name="process-request") as root_span:
#     # Add metadata to this specific observation only
#     root_span.update(metadata={"stage": "parsing"})
 
#     # ... or access span via the current context
#     langfuse.update_current_span(metadata={"stage": "parsing"})

# # Flush events in short-lived applications
# langfuse.flush()


# %%
# # Verify connection
# if langfuse.auth_check():
#     print("Langfuse client is authenticated and ready!")
# else:
#     print("Authentication failed. Please check your credentials and host.")
# %%