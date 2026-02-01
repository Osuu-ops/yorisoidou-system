## CARD: BLAST_RADIUS (Change Boundary)

### Purpose
Declare what may change / must not change, to enforce "stop on unexpected change".

### Template (minimum fields)
- allowed_paths: glob/path prefixes allowed to change
- forbidden_paths: glob/path prefixes forbidden to change
- allowed_behaviors: allowed behavior changes
- forbidden_behaviors: forbidden behavior changes
- stop_condition: any diff outside allowed => fail gate

### Enforcement (future)
- diff classifier in CI to verify change boundary
