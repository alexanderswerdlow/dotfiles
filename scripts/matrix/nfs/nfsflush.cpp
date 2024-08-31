/* nfsflush <https://github.com/andrep/nfsflush>

   See above link for documentation and licensing.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <string>

void flushAttributeCache(const std::string& path)
{
  static const int OPEN_FLAGS = 0;

  const int fileDescriptor = open(path.c_str(), OPEN_FLAGS);
  if(fileDescriptor == -1)
  {
    perror("open() failed");
    exit(3);
  }

  const int closeValue = close(fileDescriptor);
  if(closeValue == -1)
  {
    perror("close() failed");
    exit(4);
  }
}

std::string currentDirectory()
{
  char buffer[PATH_MAX];

  const char* const getcwdCall = getcwd(buffer, PATH_MAX);
  if(getcwdCall == NULL)
  {
    perror("getcwd() failed");
    exit(2);
  }

  return std::string(buffer);
}

int main(const int argc, const char* const argv[])
{
  if(argc < 2)
  {
    fprintf(stderr, "usage: %s PATH...\n", argv[0]);
    return 1;
  }

  const std::string& cwd = currentDirectory();

  for(int i = 1; i < argc; i++)
  {
    std::string path(argv[i]);
    if(path[0] != '/')
    {
      path = cwd + "/" + path;
    }

    char realPathBuffer[PATH_MAX];
    realpath(path.c_str(), realPathBuffer);
    path = std::string(realPathBuffer);

    const size_t lastSlashPosition = path.rfind('/');
    const std::string parentPath(path, 0, lastSlashPosition);

    flushAttributeCache(parentPath);
    flushAttributeCache(path);
  }
}