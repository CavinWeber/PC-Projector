float getCPUTemp()
{
    if (accessLock)
    {
      // If another process is using the socket, do nothing and return last value.
      return currentCPUTemp;
    }
    else
    {  
      if (millis() - CPUTempTimer > 500)
      {
        // Otherwise, if we haven't updated the CPU value in a while, do that and return new value.
        accessLock = true;
        CPUTempTimer = millis();
        String reception = null;
        myClient.write("CPUTEMP");
        while (reception == null)
        {
          // Keep polling the socket until we get a response. (If this is not threaded it will block other executions.)
          reception = myClient.readString();
        }
        print("Cpu temp is: ");
        println(reception);
        accessLock = false;
        if (reception != null)
          {
            // Double-check that we got a real response, then update global variable and return it too.
            currentCPUTemp = float(reception);
            return float(reception);
          }
          else
            {
              return currentCPUTemp;
            }
        }
      else
        {
          return currentCPUTemp;
        }
    }

}

float getGPUTemp()
  {
    if (accessLock)
      {
        return currentGPUTemp;
      }
    else
    {
    if (millis() - GPUTempTimer > 500)
    {
        accessLock = true;
        GPUTempTimer = millis();
        myClient.write("GPUTEMP");
        String reception = null;
        while (reception == null)
        {
          reception = myClient.readString();
        }
        print("Gpu temp is: ");
        println(reception);
        accessLock = false;
        currentGPUTemp = float(reception);
        return float(reception);
      }
      else
        {
          return currentGPUTemp;
        }
    }  
  }

float getGPULoad()
  {
    if (accessLock)
    {
      return currentGPULoad;
    }
    else
    {
      if (millis() - GPULoadTimer > 1000)
      {
        accessLock = true;
        GPULoadTimer = millis();
        myClient.write("GPULOAD");
        String reception = null;
        while (reception == null)
        {
          reception = myClient.readString();
        }
        print("Gpu load is: ");
        println(reception);
        accessLock = false;
        currentGPULoad = float(reception);
        return float(reception);
      }
      else
        {
          return currentGPULoad;
        }
    }  
  }
