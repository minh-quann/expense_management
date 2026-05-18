import os
import re

def fix_file(path):
    with open(path, 'r') as f:
        content = f.read()

    # Fix double contexts
    content = content.replace('(context)(context)', '(context)')
    
    # Remove const before AppText, TextStyle, Icon, BoxDecoration when they contain context calls
    def remove_const(match):
        text = match.group(0)
        if '(context)' in text:
            return text.replace('const ', '')
        return text

    content = re.sub(r'const\s+(?:AppText|TextStyle|Icon|BoxDecoration|FaIcon)\s*\([^;]*?(?:\)[,\)]|;)', remove_const, content, flags=re.DOTALL)
    
    with open(path, 'w') as f:
        f.write(content)

for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            fix_file(os.path.join(root, f))
